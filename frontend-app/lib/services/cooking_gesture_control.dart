// lib/services/cooking_gesture_control.dart
import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

/// 手势类型枚举
enum GestureType {
  handUp, // 举手/向上挥手 - 下一步
  handDown, // 向下挥手 - 上一步
  fist, // 握拳 - 重复步骤
  openHand, // 张开手掌 - 暂停
  okSign, // OK手势 - 完成
  none, // 无手势
}

/// 手势控制服务类
class CookingGestureControl {
  CameraController? _cameraController;
  PoseDetector? _poseDetector;
  StreamSubscription<CameraImage>? _imageStreamSubscription;
  CameraDescription? _cameraDescription; // 保存摄像头描述，用于旋转角度计算

  bool _isInitialized = false;
  bool _isActive = false;
  bool _isBusy = false; // 防止并发处理图像

  // 手势识别回调
  Function(GestureType)? onGestureDetected;

  // 防抖控制
  GestureType _lastDetectedGesture = GestureType.none;
  DateTime _lastGestureTime = DateTime(0);
  // 增加防抖时间到 2.5 秒，避免频繁触发
  static const Duration _debounceDuration = Duration(milliseconds: 2500);

  // 添加稳定性检查：要求手势在连续几帧中都保持一致
  GestureType? _pendingGesture; // 待确认的手势
  int _gestureStabilityCount = 0; // 手势稳定计数
  static const int _requiredStabilityFrames = 5; // 需要连续5帧保持一致（增加稳定性要求）

  // 设备方向映射（用于旋转角度计算）
  static final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };
  DeviceOrientation _currentRotation = DeviceOrientation.portraitUp;

  /// 初始化手势控制
  Future<bool> initialize() async {
    debugPrint('[GestureControl] ===== initialize() 开始 =====');
    debugPrint('[GestureControl] 当前初始化状态: $_isInitialized');

    if (_isInitialized) {
      debugPrint('[GestureControl] 已经初始化，直接返回 true');
      return true;
    }

    try {
      debugPrint('[GestureControl] 开始获取可用摄像头...');
      // 获取可用摄像头
      final cameras = await availableCameras();
      debugPrint('[GestureControl] 找到 ${cameras.length} 个摄像头');

      if (cameras.isEmpty) {
        debugPrint('[GestureControl] ❌ 没有可用的摄像头');
        debugPrint('[GestureControl] ===== initialize() 失败 =====');
        return false;
      }

      // 使用前置摄像头（用户面向屏幕）
      debugPrint('[GestureControl] 查找前置摄像头...');
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      debugPrint(
        '[GestureControl] 选择的摄像头: ${frontCamera.name}, 方向: ${frontCamera.lensDirection}',
      );

      // 保存摄像头描述，用于后续旋转角度计算
      _cameraDescription = frontCamera;

      // 初始化摄像头控制器
      debugPrint('[GestureControl] 初始化摄像头控制器...');
      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium, // 中等分辨率，平衡性能和准确度
        enableAudio: false,
      );

      debugPrint('[GestureControl] 等待摄像头初始化完成...');
      await _cameraController!.initialize();
      debugPrint('[GestureControl] ✅ 摄像头初始化成功');

      // 初始化姿态检测器
      debugPrint('[GestureControl] 初始化姿态检测器...');
      _poseDetector = PoseDetector(
        options: PoseDetectorOptions(mode: PoseDetectionMode.stream),
      );
      debugPrint('[GestureControl] ✅ 姿态检测器初始化成功');

      _isInitialized = true;
      debugPrint('[GestureControl] ✅ 初始化成功！_isInitialized = true');
      debugPrint('[GestureControl] ===== initialize() 完成 =====');
      return true;
    } catch (e, stackTrace) {
      debugPrint('[GestureControl] ❌ 初始化异常: $e');
      debugPrint('[GestureControl] 异常类型: ${e.runtimeType}');
      debugPrint('[GestureControl] 堆栈跟踪:');
      debugPrint(stackTrace.toString());
      debugPrint('[GestureControl] ===== initialize() 失败 =====');
      return false;
    }
  }

  /// 开始手势识别
  Future<void> startDetection() async {
    debugPrint('[GestureControl] ===== startDetection() 开始 =====');
    debugPrint(
      '[GestureControl] 当前状态: _isInitialized=$_isInitialized, _isActive=$_isActive',
    );

    if (!_isInitialized) {
      debugPrint('[GestureControl] 未初始化，尝试初始化...');
      final initialized = await initialize();
      debugPrint('[GestureControl] 初始化结果: $initialized');

      if (!initialized) {
        debugPrint('[GestureControl] ❌ 初始化失败，无法开始检测');
        debugPrint('[GestureControl] ===== startDetection() 失败 =====');
        return;
      }
      debugPrint('[GestureControl] ✅ 初始化成功');
    }

    if (_isActive) {
      debugPrint('[GestureControl] ⚠️ 已经在检测中，直接返回');
      debugPrint('[GestureControl] ===== startDetection() 跳过 =====');
      return;
    }

    try {
      // 清理之前的状态和任务队列
      debugPrint('[GestureControl] 清理之前的状态...');
      _lastDetectedGesture = GestureType.none;
      _lastGestureTime = DateTime(0);
      _pendingGesture = null;
      _gestureStabilityCount = 0;
      _isBusy = false; // 确保不处于忙碌状态

      debugPrint('[GestureControl] 设置 _isActive = true');
      _isActive = true;

      debugPrint('[GestureControl] 开始图像流...');
      // 开始图像流
      await _cameraController!.startImageStream(_processImage);

      debugPrint('[GestureControl] ✅ 检测已启动，图像流已开始');
      debugPrint('[GestureControl] ===== startDetection() 成功 =====');
    } catch (e, stackTrace) {
      _isActive = false;
      debugPrint('[GestureControl] ❌ 启动检测异常: $e');
      debugPrint('[GestureControl] 异常类型: ${e.runtimeType}');
      debugPrint('[GestureControl] 堆栈跟踪:');
      debugPrint(stackTrace.toString());
      debugPrint('[GestureControl] ===== startDetection() 失败 =====');
    }
  }

  /// 停止手势识别
  Future<void> stopDetection() async {
    debugPrint('[GestureControl] ===== stopDetection() 开始 =====');
    debugPrint('[GestureControl] 当前状态: _isActive=$_isActive, _isBusy=$_isBusy');

    if (!_isActive) {
      debugPrint('[GestureControl] ⚠️ 未在检测中，直接返回');
      debugPrint('[GestureControl] ===== stopDetection() 跳过 =====');
      return;
    }

    try {
      // 第一步：立即设置标志，阻止新的处理任务
      debugPrint('[GestureControl] 设置 _isActive = false');
      _isActive = false;

      // 第二步：立即清理回调，防止停止后还触发回调
      debugPrint('[GestureControl] 清理手势回调...');
      onGestureDetected = null;

      // 第三步：停止图像流（这会停止新的图像帧，但已进入队列的仍会处理）
      debugPrint('[GestureControl] 停止图像流...');
      try {
        await _cameraController?.stopImageStream();
        debugPrint('[GestureControl] ✅ 图像流已停止');
      } catch (e) {
        debugPrint('[GestureControl] ⚠️ 停止图像流时出错: $e');
        // 继续执行，不因这个错误而中断
      }

      // 第四步：取消图像流订阅（如果存在）
      debugPrint('[GestureControl] 取消图像流订阅...');
      _imageStreamSubscription?.cancel();
      _imageStreamSubscription = null;

      // 第五步：等待正在处理的任务完成（最多等待 1.5 秒）
      debugPrint('[GestureControl] 等待正在处理的任务完成...');
      int waitCount = 0;
      while (_isBusy && waitCount < 15) {
        await Future.delayed(const Duration(milliseconds: 100));
        waitCount++;
        if (waitCount % 5 == 0) {
          debugPrint('[GestureControl] 仍在等待... (${waitCount * 100}ms)');
        }
      }
      if (_isBusy) {
        debugPrint('[GestureControl] ⚠️ 等待超时，强制重置 _isBusy');
        _isBusy = false;
      } else {
        debugPrint('[GestureControl] ✅ 所有任务已完成');
      }

      // 第六步：重置状态
      debugPrint('[GestureControl] 重置上次检测的手势');
      _lastDetectedGesture = GestureType.none;
      _lastGestureTime = DateTime(0);
      _pendingGesture = null; // 重置待确认手势
      _gestureStabilityCount = 0; // 重置稳定性计数

      debugPrint('[GestureControl] ✅ 检测已停止');
      debugPrint('[GestureControl] ===== stopDetection() 完成 =====');
    } catch (e, stackTrace) {
      debugPrint('[GestureControl] ❌ 停止检测异常: $e');
      debugPrint('[GestureControl] 异常类型: ${e.runtimeType}');
      debugPrint('[GestureControl] 堆栈跟踪:');
      debugPrint(stackTrace.toString());
      debugPrint('[GestureControl] ===== stopDetection() 失败 =====');
      // 即使出错，也要确保状态被重置
      _isActive = false;
      _isBusy = false;
      onGestureDetected = null;
    }
  }

  /// 处理摄像头图像
  Future<void> _processImage(CameraImage image) async {
    // 第一层检查：在方法开始时（最优先检查，避免不必要的处理）
    // 这是最关键的检查，一旦 _isActive 为 false，立即返回
    if (!_isActive) {
      // 静默返回，避免日志刷屏
      // debugPrint('[GestureControl] ⚠️ _processImage: _isActive=false，跳过处理');
      return;
    }

    // 第二层检查：确保检测器存在且不忙
    if (_poseDetector == null) {
      // 静默返回
      return;
    }

    if (_isBusy) {
      // 静默返回，避免日志刷屏
      return;
    }

    // 第三层检查：在设置 _isBusy 之前再次检查（防止竞态条件）
    if (!_isActive) {
      return;
    }

    _isBusy = true;

    try {
      // 转换为 InputImage（需要传入 CameraDescription 用于旋转角度计算）
      if (_cameraDescription == null) {
        debugPrint('[GestureControl] ⚠️ CameraDescription 未设置，无法处理图像');
        _isBusy = false;
        return;
      }

      final inputImage = _inputImageFromCameraImage(image, _cameraDescription!);
      if (inputImage == null) {
        // 静默返回，避免日志刷屏
        _isBusy = false;
        return;
      }

      // 第二层检查：在调用 ML Kit 之前
      if (!_isActive) {
        _isBusy = false;
        return;
      }

      // 检测姿态
      final poses = await _poseDetector!.processImage(inputImage);

      // 第三层检查：在 ML Kit 处理完成后
      if (!_isActive) {
        _isBusy = false;
        return;
      }

      if (poses.isNotEmpty) {
        final pose = poses.first;
        final gesture = _recognizeGesture(pose);

        // 第四层检查：在调用回调之前
        if (!_isActive) {
          _isBusy = false;
          return;
        }

        // 改进的防抖和稳定性检查
        final now = DateTime.now();
        final timeSinceLastGesture = now.difference(_lastGestureTime);

        if (gesture != GestureType.none) {
          // 稳定性检查：要求手势在连续几帧中都保持一致
          if (gesture == _pendingGesture) {
            _gestureStabilityCount++;
          } else {
            // 手势改变，重置计数
            _pendingGesture = gesture;
            _gestureStabilityCount = 1;
          }

          // 只有当手势稳定且满足防抖条件时才触发
          // 注意：即使手势稳定，也必须等待防抖时间
          final isStable = _gestureStabilityCount >= _requiredStabilityFrames;
          final debouncePassed = timeSinceLastGesture > _debounceDuration;

          if (isStable && debouncePassed) {
            // 保存稳定帧数用于调试（在重置前）
            final stableFrames = _gestureStabilityCount;

            // 更新最后检测到的手势和时间
            _lastDetectedGesture = gesture;
            _lastGestureTime = now;
            _gestureStabilityCount = 0; // 重置计数
            _pendingGesture = null; // 清空待确认手势

            // 最后一次检查：确保在调用回调时仍然激活
            if (_isActive && onGestureDetected != null) {
              debugPrint(
                '[GestureControl] ✅ 检测到手势并触发: $gesture (稳定帧数: $stableFrames, 防抖时间: ${timeSinceLastGesture.inMilliseconds}ms)',
              );
              try {
                onGestureDetected!(gesture);
              } catch (e, stackTrace) {
                debugPrint('[GestureControl] ❌ 回调调用异常: $e');
                debugPrint('[GestureControl] 堆栈跟踪: $stackTrace');
              }
            }
          }
          // 注意：不满足条件时不触发，也不输出日志（避免刷屏）
        } else {
          // 没有检测到手势，重置稳定性计数
          _pendingGesture = null;
          _gestureStabilityCount = 0;
        }
      }
    } catch (e, stackTrace) {
      // 只有在激活状态下才打印错误，避免停止后的错误日志
      if (_isActive) {
        debugPrint('[GestureControl] ❌ 处理图像异常: $e');
        debugPrint('[GestureControl] 异常类型: ${e.runtimeType}');
        debugPrint('[GestureControl] 堆栈跟踪:');
        debugPrint(stackTrace.toString());
      }
    } finally {
      _isBusy = false;
    }
  }

  /// 从 CameraImage 创建 InputImage（修复 ImageFormat 不支持的问题）
  InputImage? _inputImageFromCameraImage(
    CameraImage image,
    CameraDescription camera,
  ) {
    try {
      // 1. 计算旋转角度
      final sensorOrientation = camera.sensorOrientation;
      InputImageRotation? rotation;

      if (Platform.isIOS) {
        rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
      } else if (Platform.isAndroid) {
        var rotationCompensation = _orientations[_currentRotation] ?? 0;
        if (camera.lensDirection == CameraLensDirection.front) {
          // 前置摄像头需要镜像处理
          rotationCompensation =
              (sensorOrientation + rotationCompensation) % 360;
        } else {
          // 后置摄像头
          rotationCompensation =
              (sensorOrientation - rotationCompensation + 360) % 360;
        }
        rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
      }

      // 如果计算不出旋转，默认用 rotation0
      rotation ??= InputImageRotation.rotation0deg;

      // 2. 将 Plane 数据拼接成 Bytes
      // 注意：如果只有一个平面且是 bgra8888，可以直接使用
      if (image.planes.length != 1 &&
          image.format.group != ImageFormatGroup.bgra8888) {
        final WriteBuffer allBytes = WriteBuffer();
        for (final Plane plane in image.planes) {
          allBytes.putUint8List(plane.bytes);
        }
        final bytes = allBytes.done().buffer.asUint8List();

        // ⚠️ 关键修复：Android 强制使用 nv21 格式
        final targetFormat = Platform.isAndroid
            ? InputImageFormat.nv21
            : InputImageFormat.bgra8888;

        final inputImageData = InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation, // 必须正确，否则识别率极低
          format: targetFormat, // Android 强制 nv21，iOS 使用 bgra8888
          bytesPerRow: image.planes[0].bytesPerRow, // 重要参数
        );

        return InputImage.fromBytes(bytes: bytes, metadata: inputImageData);
      }

      return null;
    } catch (e) {
      // 只在激活状态下打印错误，避免停止后的错误日志
      if (_isActive) {
        debugPrint('[GestureControl] ❌ 创建 InputImage 异常: $e');
      }
      return null;
    }
  }

  /// 识别手势类型（使用姿态检测 API）
  /// 注意：姿态检测只能检测手腕、肘部等关键点，不能检测手指细节
  /// 因此手势识别逻辑被简化为基于手腕位置的基本判断
  GestureType _recognizeGesture(Pose pose) {
    final landmarks = pose.landmarks;

    if (landmarks.isEmpty) {
      return GestureType.none;
    }

    // 获取手腕和肩膀关键点（姿态检测可检测的关键点）
    final leftWrist = landmarks[PoseLandmarkType.leftWrist];
    final rightWrist = landmarks[PoseLandmarkType.rightWrist];
    final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = landmarks[PoseLandmarkType.rightShoulder];

    // 优先使用左侧手腕（用户面向屏幕时的左侧）
    final wrist = leftWrist ?? rightWrist;
    final shoulder = leftShoulder ?? rightShoulder;

    if (wrist == null || shoulder == null) {
      return GestureType.none;
    }

    // 计算手腕相对于肩膀的位置
    final wristY = wrist.y;
    final shoulderY = shoulder.y;
    final deltaY = wristY - shoulderY;

    // 增加阈值，减少误检测（从 0.25 增加到 0.3，更严格）
    // 举手/向上挥手：手腕Y坐标明显小于肩膀Y坐标（向上）
    if (deltaY < -0.3) {
      return GestureType.handUp;
    }

    // 向下挥手：手腕Y坐标明显大于肩膀Y坐标（向下）
    if (deltaY > 0.3) {
      return GestureType.handDown;
    }

    // 注意：由于姿态检测不能检测手指细节，以下手势无法精确识别
    // 如果需要这些手势，建议使用其他方案或简化交互逻辑
    // - fist (握拳)
    // - openHand (张开手掌)
    // - okSign (OK手势)

    return GestureType.none;
  }

  /// 获取摄像头控制器（用于显示预览）
  CameraController? get cameraController => _cameraController;

  /// 是否正在检测
  bool get isActive => _isActive;

  /// 是否已初始化
  bool get isInitialized => _isInitialized;

  /// 清理资源
  Future<void> dispose() async {
    debugPrint('[GestureControl] ===== dispose() 开始 =====');

    // 强制停止检测
    _isActive = false;
    onGestureDetected = null;

    // 等待停止完成
    await stopDetection();

    // 清理资源
    try {
      await _cameraController?.dispose();
      _cameraController = null;
    } catch (e) {
      debugPrint('[GestureControl] ⚠️ 清理摄像头控制器时出错: $e');
    }

    try {
      await _poseDetector?.close();
      _poseDetector = null;
    } catch (e) {
      debugPrint('[GestureControl] ⚠️ 清理姿态检测器时出错: $e');
    }

    _imageStreamSubscription?.cancel();
    _imageStreamSubscription = null;
    _isInitialized = false;
    _isBusy = false;

    debugPrint('[GestureControl] ✅ dispose() 完成');
    debugPrint('[GestureControl] ===== dispose() 结束 =====');
  }
}
