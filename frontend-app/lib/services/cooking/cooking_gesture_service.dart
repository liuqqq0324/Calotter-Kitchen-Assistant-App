import 'dart:async';
import 'dart:io';
import 'dart:math'; // 引入 max
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

enum GestureType {
  nextStep, // 右挥
  previousStep, // 左挥
  startTimer, // 上抬 (新增)
  markDone, // 下切 (新增)
}

class CookingGestureService {
  static final CookingGestureService _instance =
      CookingGestureService._internal();
  factory CookingGestureService() => _instance;
  CookingGestureService._internal();

  CameraController? _cameraController;
  PoseDetector? _poseDetector;

  bool _isDetecting = false;
  bool _isProcessing = false;
  DateTime _lastProcessTime = DateTime.fromMillisecondsSinceEpoch(0);

  bool _isCoolingDown = false;

  // ✅ 修改1: 缓冲区记录 Point (同时记录 x 和 y)
  final List<MapEntry<int, Point<double>>> _movementBuffer = [];

  // 缓冲区更大以捕捉更完整的挥动轨迹
  final int _bufferSize = 5;
  final int _cooldownMs = 1200; // 1.2秒冷却
  final int _throttleMs = 100; // 100ms 采样，更跟手

  // 降低触发门槛，更灵敏（配合 UI 层防抖防误触）
  final double _minDistanceX = 20.0;
  final double _minDistanceY = 20.0;
  final double _minVelocity = 0.25; // 允许慵懒挥手

  Function(GestureType)? onGestureDetected;

  Future<void> initialize() async {
    if (_cameraController != null) return;

    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      debugPrint('[Gesture] No cameras found');
      return;
    }

    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.low, // 保持低分辨率
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.yuv420
          : ImageFormatGroup.bgra8888,
    );

    try {
      await _cameraController!.initialize();
      final options = PoseDetectorOptions(
        mode: PoseDetectionMode.stream,
        model: PoseDetectionModel.base,
      );
      _poseDetector = PoseDetector(options: options);
      debugPrint('[Gesture] Service Initialized (4-Direction Mode)');
    } catch (e) {
      debugPrint('[Gesture] Init Error: $e');
    }
  }

  void startListening(Function(GestureType) onDetected) {
    if (_cameraController == null || !_cameraController!.value.isInitialized)
      return;
    if (_isDetecting) return;

    onGestureDetected = onDetected;
    _isDetecting = true;

    _movementBuffer.clear();
    _isCoolingDown = false;
    _isProcessing = false;

    try {
      _cameraController!.startImageStream(_processCameraImage);
      debugPrint('[Gesture] Stream Started');
    } catch (e) {
      debugPrint('[Gesture] Stream Error: $e');
    }
  }

  Future<void> stopListening() async {
    if (!_isDetecting) return;
    _isDetecting = false;
    onGestureDetected = null;
    try {
      if (_cameraController != null &&
          _cameraController!.value.isStreamingImages) {
        await _cameraController!.stopImageStream();
      }
    } catch (e) {}
    debugPrint('[Gesture] Stream Stopped');
  }

  Future<void> dispose() async {
    await stopListening();
    await _poseDetector?.close();
    await _cameraController?.dispose();
    _cameraController = null;
    _poseDetector = null;
  }

  void _processCameraImage(CameraImage image) async {
    if (_isCoolingDown || !_isDetecting) return;
    if (_isProcessing) return;

    // 采样间隔
    if (DateTime.now().difference(_lastProcessTime).inMilliseconds <
        _throttleMs)
      return;

    _isProcessing = true;
    _lastProcessTime = DateTime.now();

    try {
      final inputImage = _inputImageFromCameraImage(image);
      if (inputImage == null) return;

      final List<Pose> poses = await _poseDetector!.processImage(inputImage);

      if (poses.isNotEmpty) {
        final pose = poses.first;
        final wrist = pose.landmarks[PoseLandmarkType.rightWrist];

        // 提高置信度阈值，防止背景噪点在低动作阈值下误触
        if (wrist != null && wrist.likelihood > 0.5) {
          _analyzeTrend(wrist.x, wrist.y);
        }
      }
    } catch (e) {
      // ignore
    } finally {
      _isProcessing = false;
    }
  }

  // ✅ 核心修改：4方向趋势分析（带速度校验）
  void _analyzeTrend(double currentX, double currentY) {
    final now = DateTime.now().millisecondsSinceEpoch;
    // 存入 Point
    _movementBuffer.add(MapEntry(now, Point(currentX, currentY)));

    if (_movementBuffer.length > _bufferSize) {
      _movementBuffer.removeAt(0);
    }

    if (_movementBuffer.length < 3) return;

    final int startT = _movementBuffer.first.key;
    final int endT = _movementBuffer.last.key;
    final Point<double> start = _movementBuffer.first.value;
    final Point<double> end = _movementBuffer.last.value;

    // 计算 X 和 Y 的净位移
    final double diffX = end.x - start.x;
    final double diffY = end.y - start.y;

    // 计算时间差
    final int timeDiff = endT - startT;

    // debugPrint('[Gesture] dX: ${diffX.toStringAsFixed(1)}, dY: ${diffY.toStringAsFixed(1)}');

    // 1. 判断是否触发了任何距离阈值
    bool xTriggered = diffX.abs() > _minDistanceX;
    bool yTriggered = diffY.abs() > _minDistanceY;

    if (xTriggered || yTriggered) {
      // 2. 方向主导性校验：主轴必须明显大于副轴，防止斜向挥手误判
      bool isHorizontal = diffX.abs() > diffY.abs() * 1.2;
      bool isVertical = diffY.abs() > diffX.abs() * 1.2;

      if (isHorizontal) {
        // --- 水平移动 ---
        final double velocityX = timeDiff > 0 ? diffX.abs() / timeDiff : 0.0;

        debugPrint(
          '[Gesture] X-Move: Dist=${diffX.abs().toStringAsFixed(1)}, Vel=${velocityX.toStringAsFixed(3)}',
        );

        if (diffX.abs() > _minDistanceX && velocityX > _minVelocity) {
          if (diffX > 0) {
            debugPrint('[Gesture] 👉 RIGHT (Next)');
            _triggerCooldown(GestureType.nextStep);
          } else {
            debugPrint('[Gesture] 👈 LEFT (Prev)');
            _triggerCooldown(GestureType.previousStep);
          }
        }
      } else if (isVertical) {
        // --- 垂直移动 ---
        final double velocityY = timeDiff > 0 ? diffY.abs() / timeDiff : 0.0;

        debugPrint(
          '[Gesture] Y-Move: Dist=${diffY.abs().toStringAsFixed(1)}, Vel=${velocityY.toStringAsFixed(3)}',
        );

        if (diffY.abs() > _minDistanceY && velocityY > _minVelocity) {
          // 图像坐标系 Y 向下增加：diffY < 0 向上，diffY > 0 向下
          if (diffY < 0) {
            debugPrint('[Gesture] 👆 UP (Start Timer)');
            _triggerCooldown(GestureType.startTimer);
          } else {
            debugPrint('[Gesture] 👇 DOWN (Mark Done)');
            _triggerCooldown(GestureType.markDone);
          }
        }
      }
      // 斜向移动（既非明显水平也非明显垂直）则忽略
    }
  }

  void _triggerCooldown(GestureType type) {
    _isCoolingDown = true;
    _movementBuffer.clear();

    if (onGestureDetected != null) {
      onGestureDetected!(type);
    }

    Timer(Duration(milliseconds: _cooldownMs), () {
      _isCoolingDown = false;
      debugPrint('[Gesture] Ready');
    });
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_cameraController == null) return null;
    final camera = _cameraController!.description;
    final sensorOrientation = camera.sensorOrientation;

    InputImageRotation? rotation;
    if (Platform.isAndroid) {
      var rotationCompensation =
          _orientations[_cameraController!.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    } else {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    }

    if (rotation == null) return null;

    // 简化处理逻辑，不再区分 iOS/Android 分支细节，统一逻辑
    // 在 Low 分辨率下，NV21 强转通常是安全的
    final format =
        InputImageFormatValue.fromRawValue(image.format.raw) ??
        InputImageFormat.nv21;

    return InputImage.fromBytes(
      bytes: _concatenatePlanes(image.planes),
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: Platform.isAndroid ? InputImageFormat.nv21 : format,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );
  }

  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  Uint8List _concatenatePlanes(List<Plane> planes) {
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
  }
}
