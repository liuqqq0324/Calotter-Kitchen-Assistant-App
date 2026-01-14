// lib/services/tts_service.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// 文本转语音服务（TTS）
/// 使用系统底层的 TTS 引擎，支持离线播报
/// 即使没有 Google 服务，大多数 Android 设备也有基础的 TTS 引擎（如 Pico TTS）
class TtsService {
  // 单例模式
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  bool _isSpeaking = false;

  bool get isSpeaking => _isSpeaking;
  bool get isInitialized => _isInitialized;

  /// 初始化 TTS 引擎
  /// [language] 语言代码，如 "zh-CN"（中文）或 "en-US"（英文）
  Future<void> initialize({String language = "zh-CN"}) async {
    if (_isInitialized) {
      debugPrint('[TtsService] 已经初始化');
      return;
    }

    try {
      debugPrint('[TtsService] 开始初始化 TTS 引擎...');

      // 1. 设置语言
      // 如果是英文食谱，用 en-US。如果是中文，用 zh-CN
      final result = await _flutterTts.setLanguage(language);
      if (result == 1) {
        debugPrint('[TtsService] ✅ 语言设置成功: $language');
      } else {
        debugPrint('[TtsService] ⚠️ 语言设置失败，尝试使用默认语言');
        // 如果设置失败，尝试使用系统默认语言
        await _flutterTts.setLanguage("en-US");
      }

      // 2. 设置语速 (0.0 ~ 1.0)
      await _flutterTts.setSpeechRate(0.5);
      debugPrint('[TtsService] 语速设置为: 0.5');

      // 3. 设置音量 (0.0 ~ 1.0)
      await _flutterTts.setVolume(1.0);
      debugPrint('[TtsService] 音量设置为: 1.0');

      // 4. 设置音调 (0.5 ~ 2.0)
      await _flutterTts.setPitch(1.0);
      debugPrint('[TtsService] 音调设置为: 1.0');

      // 5. 等待引擎初始化（Android 上这步很重要）
      await _flutterTts.awaitSpeakCompletion(true);
      debugPrint('[TtsService] 等待播报完成设置为: true');

      // 设置完成回调
      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
        debugPrint('[TtsService] ✅ 播报完成');
      });

      // 设置错误回调
      _flutterTts.setErrorHandler((msg) {
        _isSpeaking = false;
        debugPrint('[TtsService] ❌ TTS 错误: $msg');
      });

      _isInitialized = true;
      debugPrint('[TtsService] ✅ TTS 引擎初始化成功');
    } catch (e, stackTrace) {
      debugPrint('[TtsService] ❌ TTS 初始化失败: $e');
      debugPrint('[TtsService] 堆栈跟踪:');
      debugPrint(stackTrace.toString());
      debugPrint('[TtsService] 提示: 如果设备没有 TTS 引擎，请安装 Google Text-to-Speech APK 或 eSpeak TTS APK');
    }
  }

  /// 播报文本
  /// [text] 要播报的文本内容
  Future<void> speak(String text) async {
    if (text.isEmpty) {
      debugPrint('[TtsService] ⚠️ 文本为空，跳过播报');
      return;
    }

    if (!_isInitialized) {
      debugPrint('[TtsService] ⚠️ TTS 未初始化，尝试初始化...');
      await initialize();
      if (!_isInitialized) {
        debugPrint('[TtsService] ❌ TTS 初始化失败，无法播报');
        return;
      }
    }

    try {
      // 如果正在播报，先停止
      if (_isSpeaking) {
        debugPrint('[TtsService] 正在播报中，先停止当前播报');
        await stop();
      }

      _isSpeaking = true;
      debugPrint('[TtsService] 🔊 开始播报: $text');
      await _flutterTts.speak(text);
    } catch (e, stackTrace) {
      _isSpeaking = false;
      debugPrint('[TtsService] ❌ 播报失败: $e');
      debugPrint('[TtsService] 堆栈跟踪:');
      debugPrint(stackTrace.toString());
    }
  }

  /// 停止播报
  Future<void> stop() async {
    if (_isSpeaking) {
      try {
        debugPrint('[TtsService] 停止播报');
        await _flutterTts.stop();
        _isSpeaking = false;
        debugPrint('[TtsService] ✅ 播报已停止');
      } catch (e) {
        debugPrint('[TtsService] ❌ 停止播报失败: $e');
        _isSpeaking = false;
      }
    }
  }

  /// 暂停播报（如果支持）
  Future<void> pause() async {
    if (_isSpeaking) {
      try {
        await _flutterTts.pause();
        debugPrint('[TtsService] 播报已暂停');
      } catch (e) {
        debugPrint('[TtsService] ⚠️ 暂停功能可能不支持: $e');
      }
    }
  }

  /// 设置语言
  /// [language] 语言代码，如 "zh-CN" 或 "en-US"
  Future<void> setLanguage(String language) async {
    try {
      final result = await _flutterTts.setLanguage(language);
      if (result == 1) {
        debugPrint('[TtsService] ✅ 语言已更新为: $language');
      } else {
        debugPrint('[TtsService] ⚠️ 语言更新失败: $language');
      }
    } catch (e) {
      debugPrint('[TtsService] ❌ 设置语言失败: $e');
    }
  }

  /// 设置语速
  /// [rate] 语速，范围 0.0 ~ 1.0
  Future<void> setSpeechRate(double rate) async {
    try {
      await _flutterTts.setSpeechRate(rate.clamp(0.0, 1.0));
      debugPrint('[TtsService] 语速已更新为: ${rate.clamp(0.0, 1.0)}');
    } catch (e) {
      debugPrint('[TtsService] ❌ 设置语速失败: $e');
    }
  }

  /// 设置音量
  /// [volume] 音量，范围 0.0 ~ 1.0
  Future<void> setVolume(double volume) async {
    try {
      await _flutterTts.setVolume(volume.clamp(0.0, 1.0));
      debugPrint('[TtsService] 音量已更新为: ${volume.clamp(0.0, 1.0)}');
    } catch (e) {
      debugPrint('[TtsService] ❌ 设置音量失败: $e');
    }
  }

  /// 设置音调
  /// [pitch] 音调，范围 0.5 ~ 2.0
  Future<void> setPitch(double pitch) async {
    try {
      await _flutterTts.setPitch(pitch.clamp(0.5, 2.0));
      debugPrint('[TtsService] 音调已更新为: ${pitch.clamp(0.5, 2.0)}');
    } catch (e) {
      debugPrint('[TtsService] ❌ 设置音调失败: $e');
    }
  }

  /// 释放资源
  Future<void> dispose() async {
    debugPrint('[TtsService] 释放资源...');
    await stop();
    _isInitialized = false;
    debugPrint('[TtsService] ✅ 资源已释放');
  }
}

