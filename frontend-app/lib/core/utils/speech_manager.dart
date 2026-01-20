// lib/utils/speech_manager.dart
import 'package:flutter/foundation.dart';

/// Speech manager stub - simplified implementation
class SpeechManager {
  Function(String)? onResult;
  Function(String)? onError;

  bool _isReady = false;
  bool _isListening = false;

  /// Initialize speech recognition (stub)
  Future<void> init() async {
    debugPrint('[SpeechManager] Speech recognition stub - initialization skipped');
    _isReady = false;
  }

  /// Start listening (stub)
  void startListening() {
    debugPrint('[SpeechManager] Speech recognition stub - listening not supported');
    _isListening = false;
  }

  /// Stop listening (stub)
  void stopListening() {
    debugPrint('[SpeechManager] Speech recognition stub - stopped');
    _isListening = false;
  }

  /// Cleanup resources
  void dispose() {
    debugPrint('[SpeechManager] Speech recognition stub - disposed');
    _isReady = false;
    _isListening = false;
  }

  /// Whether initialized
  bool get isReady => _isReady;

  /// Whether listening
  bool get isListening => _isListening;
}
