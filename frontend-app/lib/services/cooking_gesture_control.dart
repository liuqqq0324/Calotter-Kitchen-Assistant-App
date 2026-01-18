// lib/services/cooking_gesture_control.dart
import 'package:flutter/foundation.dart';

/// Gesture type enum
enum GestureType {
  handUp,
  handDown,
  fist,
  openHand,
  okSign,
  none,
}

/// Gesture control service (stub implementation)
class CookingGestureControl {
  bool _isInitialized = false;
  bool _isActive = false;

  Function(GestureType)? onGestureDetected;

  /// Initialize gesture control (stub)
  Future<bool> initialize() async {
    debugPrint('[GestureControl] Gesture control stub - initialization skipped');
    _isInitialized = false;
    return false;
  }

  /// Start gesture detection (stub)
  Future<void> startDetection() async {
    debugPrint('[GestureControl] Gesture control stub - detection not supported');
    _isActive = false;
  }

  /// Stop gesture detection (stub)
  Future<void> stopDetection() async {
    debugPrint('[GestureControl] Gesture control stub - stopped');
    _isActive = false;
  }

  /// Get camera controller (stub)
  dynamic get cameraController => null;

  /// Whether active
  bool get isActive => _isActive;

  /// Whether initialized
  bool get isInitialized => _isInitialized;

  /// Cleanup resources
  Future<void> dispose() async {
    debugPrint('[GestureControl] Gesture control stub - disposed');
    _isActive = false;
    _isInitialized = false;
    onGestureDetected = null;
  }
}
