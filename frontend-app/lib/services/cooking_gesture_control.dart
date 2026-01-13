// lib/services/cooking_gesture_control.dart
import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_hand_landmark_detection/google_mlkit_hand_landmark_detection.dart';

/// 手势类型枚举
enum GestureType {
  handUp,      // 举手/向上挥手 - 下一步
  handDown,    // 向下挥手 - 上一步
  fist,        // 握拳 - 重复步骤
  openHand,    // 张开手掌 - 暂停
  okSign,      // OK手势 - 完成
  none,        // 无手势
}

/// 手势控制服务类
class CookingGestureControl {
  CameraController? _cameraController;
  HandLandmarkDetector? _handDetector;
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
      
      // 初始化手势检测器
      _handDetector = HandLandmarkDetector(
        options: HandLandmarkDetectorOptions(
          mode: HandLandmarkMode.stream,
        ),
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
    if (!_isActive || _handDetector == null) return;
    
    try {
      // 转换为 InputImage
      final inputImage = _inputImageFromCameraImage(image);
      if (inputImage == null) return;
      
      // 检测手势
      final hands = await _handDetector!.processImage(inputImage);
      
      if (hands.isNotEmpty) {
        final gesture = _recognizeGesture(hands.first);
        
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
      
      return InputImage.fromBytes(
        bytes: bytes,
        metadata: inputImageData,
      );
    } catch (e) {
      debugPrint('[GestureControl] Error creating InputImage: $e');
      return null;
    }
  }
  
  /// 识别手势类型
  GestureType _recognizeGesture(Hand hand) {
    final landmarks = hand.landmarks;
    if (landmarks.isEmpty) return GestureType.none;
    
    // 获取关键点
    final wrist = landmarks[HandLandmarkType.wrist];
    final thumbTip = landmarks[HandLandmarkType.thumbTip];
    final indexTip = landmarks[HandLandmarkType.indexFingerTip];
    final middleTip = landmarks[HandLandmarkType.middleFingerTip];
    final ringTip = landmarks[HandLandmarkType.ringFingerTip];
    final pinkyTip = landmarks[HandLandmarkType.pinkyTip];
    
    if (wrist == null || thumbTip == null || indexTip == null || 
        middleTip == null || ringTip == null || pinkyTip == null) {
      return GestureType.none;
    }
    
    // 计算手指是否伸直（指尖 Y 坐标小于指关节 Y 坐标）
    final indexPip = landmarks[HandLandmarkType.indexFingerPip];
    final middlePip = landmarks[HandLandmarkType.middleFingerPip];
    final ringPip = landmarks[HandLandmarkType.ringFingerPip];
    final pinkyPip = landmarks[HandLandmarkType.pinkyPip];
    final thumbIp = landmarks[HandLandmarkType.thumbIp];
    
    if (indexPip == null || middlePip == null || ringPip == null || 
        pinkyPip == null || thumbIp == null) {
      return GestureType.none;
    }
    
    final indexExtended = indexTip.y < indexPip.y;
    final middleExtended = middleTip.y < middlePip.y;
    final ringExtended = ringTip.y < ringPip.y;
    final pinkyExtended = pinkyTip.y < pinkyPip.y;
    final thumbExtended = thumbTip.x > thumbIp.x; // 拇指的判断方向不同
    
    // 判断手势类型
    final extendedCount = [
      indexExtended,
      middleExtended,
      ringExtended,
      pinkyExtended,
      thumbExtended,
    ].where((e) => e).length;
    
    // 举手/向上挥手：所有手指都向上（指尖Y坐标小于手腕Y坐标）
    if (indexExtended && middleExtended && ringExtended && pinkyExtended) {
      if (indexTip.y < wrist.y && middleTip.y < wrist.y) {
        return GestureType.handUp;
      }
    }
    
    // 向下挥手：所有手指向下（指尖Y坐标大于手腕Y坐标）
    if (indexExtended && middleExtended && ringExtended && pinkyExtended) {
      if (indexTip.y > wrist.y && middleTip.y > wrist.y) {
        return GestureType.handDown;
      }
    }
    
    // OK手势：只有拇指和食指接触（其他手指弯曲）
    if (thumbExtended && indexExtended && 
        !middleExtended && !ringExtended && !pinkyExtended) {
      // 检查拇指和食指是否接近
      final distance = _calculateDistance(thumbTip, indexTip);
      if (distance < 0.05) { // 阈值需要根据实际情况调整
        return GestureType.okSign;
      }
    }
    
    // 握拳：所有手指都弯曲
    if (extendedCount == 0 || extendedCount == 1) {
      return GestureType.fist;
    }
    
    // 张开手掌：所有手指都伸直
    if (extendedCount == 5) {
      return GestureType.openHand;
    }
    
    return GestureType.none;
  }
  
  /// 计算两点之间的距离
  double _calculateDistance(Point point1, Point point2) {
    final dx = point1.x - point2.x;
    final dy = point1.y - point2.y;
    return (dx * dx + dy * dy);
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
    await _handDetector?.close();
    _cameraController = null;
    _handDetector = null;
    _isInitialized = false;
  }
}
