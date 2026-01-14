// lib/services/cooking_gesture_control.dart
import 'dart:async';
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

  bool _isInitialized = false;
  bool _isActive = false;

  // 手势识别回调
  Function(GestureType)? onGestureDetected;

  // 防抖控制
  GestureType _lastDetectedGesture = GestureType.none;
  DateTime _lastGestureTime = DateTime(0);
  static const Duration _debounceDuration = Duration(milliseconds: 500);

  /// 初始化手势控制
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // 获取可用摄像头
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        debugPrint('[GestureControl] No cameras available');
        return false;
      }

      // 使用前置摄像头（用户面向屏幕）
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      // 初始化摄像头控制器
      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium, // 中等分辨率，平衡性能和准确度
        enableAudio: false,
      );

      await _cameraController!.initialize();

      // 初始化姿态检测器
      _poseDetector = PoseDetector(
        options: PoseDetectorOptions(mode: PoseDetectionMode.stream),
      );

      _isInitialized = true;
      debugPrint('[GestureControl] Initialized successfully');
      return true;
    } catch (e) {
      debugPrint('[GestureControl] Initialization error: $e');
      return false;
    }
  }

  /// 开始手势识别
  Future<void> startDetection() async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        debugPrint('[GestureControl] Failed to initialize');
        return;
      }
    }

    if (_isActive) {
      debugPrint('[GestureControl] Already detecting');
      return;
    }

    try {
      _isActive = true;

      // 开始图像流
      await _cameraController!.startImageStream(_processImage);

      debugPrint('[GestureControl] Started detection');
    } catch (e) {
      _isActive = false;
      debugPrint('[GestureControl] Start detection error: $e');
    }
  }

  /// 停止手势识别
  Future<void> stopDetection() async {
    if (!_isActive) return;

    try {
      _isActive = false;
      await _cameraController?.stopImageStream();
      _imageStreamSubscription?.cancel();
      _imageStreamSubscription = null;

      _lastDetectedGesture = GestureType.none;

      debugPrint('[GestureControl] Stopped detection');
    } catch (e) {
      debugPrint('[GestureControl] Stop detection error: $e');
    }
  }

  /// 处理摄像头图像
  Future<void> _processImage(CameraImage image) async {
    if (!_isActive || _poseDetector == null) return;

    try {
      // 转换为 InputImage
      final inputImage = _inputImageFromCameraImage(image);
      if (inputImage == null) return;

      // 检测姿态
      final poses = await _poseDetector!.processImage(inputImage);

      if (poses.isNotEmpty) {
        final gesture = _recognizeGesture(poses.first);

        // 防抖处理
        final now = DateTime.now();
        if (gesture != GestureType.none &&
            (gesture != _lastDetectedGesture ||
                now.difference(_lastGestureTime) > _debounceDuration)) {
          _lastDetectedGesture = gesture;
          _lastGestureTime = now;

          debugPrint('[GestureControl] Detected gesture: $gesture');
          onGestureDetected?.call(gesture);
        }
      }
    } catch (e) {
      debugPrint('[GestureControl] Process image error: $e');
    }
  }

  /// 从 CameraImage 创建 InputImage
  InputImage? _inputImageFromCameraImage(CameraImage image) {
    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final imageRotation = InputImageRotation.rotation0deg; // 前置摄像头通常不需要旋转

      final inputImageData = InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: imageRotation,
        format: InputImageFormat.yuv420,
        bytesPerRow: image.planes[0].bytesPerRow,
      );

      return InputImage.fromBytes(bytes: bytes, metadata: inputImageData);
    } catch (e) {
      debugPrint('[GestureControl] Error creating InputImage: $e');
      return null;
    }
  }

  /// 识别手势类型（使用姿态检测 API）
  /// 注意：姿态检测只能检测手腕、肘部等关键点，不能检测手指细节
  /// 因此手势识别逻辑被简化为基于手腕位置的基本判断
  GestureType _recognizeGesture(Pose pose) {
    final landmarks = pose.landmarks;
    if (landmarks.isEmpty) return GestureType.none;

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

    // 举手/向上挥手：手腕Y坐标明显小于肩膀Y坐标（向上）
    if (deltaY < -0.15) {
      // 阈值需要根据实际情况调整
      return GestureType.handUp;
    }

    // 向下挥手：手腕Y坐标明显大于肩膀Y坐标（向下）
    if (deltaY > 0.15) {
      // 阈值需要根据实际情况调整
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
    await stopDetection();
    await _cameraController?.dispose();
    await _poseDetector?.close();
    _cameraController = null;
    _poseDetector = null;
    _isInitialized = false;
  }
}
