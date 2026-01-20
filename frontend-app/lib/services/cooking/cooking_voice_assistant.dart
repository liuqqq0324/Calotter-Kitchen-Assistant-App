// lib/services/cooking_voice_assistant.dart
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:personal_sous_chef/data/models/recipe_models.dart';

/// Voice command type enum
enum VoiceCommandType {
  nextStep,        // Next step
  previousStep,    // Previous step
  repeatStep,      // Repeat current step
  jumpToStep,      // Jump to specified step
  startTimer,      // Start timer
  pauseTimer,      // Pause timer
  resumeTimer,     // Resume timer
  stopTimer,       // Stop timer
  completeStep,    // Complete step
  nextDish,        // Next dish
  previousDish,    // Previous dish
  currentStepInfo, // Current step info
  timerStatus,     // Timer status
  ingredientsList,  // Ingredients list
  exitVoiceMode,   // Exit voice mode
  help,            // Help
  unknown,         // Unknown command
}

/// Voice assistant service class
class CookingVoiceAssistant {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  
  bool _isInitialized = false;
  bool _isListening = false;
  bool _isSpeaking = false;
  
  // 初始化失败标志，防止无限循环
  bool _initializationFailed = false;
  
  // 用于暂停/恢复功能
  bool _wasListeningBeforePause = false;
  Function(String)? _savedOnResult;
  Function(String)? _savedOnError;
  
  // Command keywords mapping (English only)
  static const Map<VoiceCommandType, List<String>> _commandKeywords = {
    VoiceCommandType.nextStep: [
      'next step', 'next', 'continue'
    ],
    VoiceCommandType.previousStep: [
      'previous step', 'previous', 'back', 'last step'
    ],
    VoiceCommandType.repeatStep: [
      'repeat', 'say again', 'repeat step', 'once more'
    ],
    VoiceCommandType.startTimer: [
      'start timer', 'start timing', 'begin timer'
    ],
    VoiceCommandType.pauseTimer: [
      'pause timer', 'pause', 'pause timing'
    ],
    VoiceCommandType.resumeTimer: [
      'resume timer', 'resume', 'continue timer'
    ],
    VoiceCommandType.stopTimer: [
      'stop timer', 'stop', 'cancel timer'
    ],
    VoiceCommandType.completeStep: [
      'done', 'complete', 'step done', 'mark done', 'finish'
    ],
    VoiceCommandType.nextDish: [
      'next dish', 'next recipe'
    ],
    VoiceCommandType.previousDish: [
      'previous dish', 'last dish', 'previous recipe'
    ],
    VoiceCommandType.currentStepInfo: [
      'current step', 'this step', 'now'
    ],
    VoiceCommandType.timerStatus: [
      'time left', 'remaining time', 'timer status'
    ],
    VoiceCommandType.ingredientsList: [
      'ingredients', 'ingredient list', 'what do I need'
    ],
    VoiceCommandType.exitVoiceMode: [
      'exit voice', 'exit', 'close voice mode', 'turn off'
    ],
    VoiceCommandType.help: [
      'help', 'how to use', 'commands', 'what can I say'
    ],
  };
  
  /// Check and request microphone permission
  Future<bool> checkAndRequestPermission() async {
    debugPrint('[VoiceAssistant] 检查麦克风权限...');
    
    // 检查权限状态
    final status = await Permission.microphone.status;
    debugPrint('[VoiceAssistant] 当前权限状态: $status');
    
    if (status.isGranted) {
      debugPrint('[VoiceAssistant] ✅ 权限已授予');
      return true;
    }
    
    if (status.isDenied) {
      debugPrint('[VoiceAssistant] ⚠️ 权限被拒绝，请求权限...');
      final result = await Permission.microphone.request();
      debugPrint('[VoiceAssistant] 权限请求结果: $result');
      
      if (result.isGranted) {
        debugPrint('[VoiceAssistant] ✅ 权限已授予');
        return true;
      } else if (result.isPermanentlyDenied) {
        debugPrint('[VoiceAssistant] ❌ 权限被永久拒绝，需要手动设置');
        return false;
      }
    }
    
    if (status.isPermanentlyDenied) {
      debugPrint('[VoiceAssistant] ❌ 权限被永久拒绝');
      return false;
    }
    
    return false;
  }
  
  /// Initialize voice assistant
  Future<bool> initialize() async {
    debugPrint('[VoiceAssistant] ===== initialize() 开始 =====');
    debugPrint('[VoiceAssistant] 当前初始化状态: $_isInitialized, 初始化失败标志: $_initializationFailed');
    
    // 如果之前初始化失败过，直接返回 false，不再尝试
    if (_initializationFailed) {
      debugPrint('[VoiceAssistant] ⚠️ 之前初始化已失败，不再重试');
      debugPrint('[VoiceAssistant] ===== initialize() 跳过（已失败） =====');
      return false;
    }
    
    if (_isInitialized) {
      debugPrint('[VoiceAssistant] 已经初始化，直接返回 true');
      return true;
    }
    
    try {
      // 先检查权限
      debugPrint('[VoiceAssistant] 检查麦克风权限...');
      final hasPermission = await checkAndRequestPermission();
      if (!hasPermission) {
        debugPrint('[VoiceAssistant] ❌ 没有麦克风权限，初始化失败');
        _initializationFailed = true;
        return false;
      }
      
      debugPrint('[VoiceAssistant] 开始初始化语音识别...');
      // 初始化语音识别
      final speechAvailable = await _speech.initialize(
        onError: (error) {
          debugPrint('[VoiceAssistant] ⚠️ Speech recognition error: $error');
          debugPrint('[VoiceAssistant] 错误类型: ${error.runtimeType}');
          debugPrint('[VoiceAssistant] 错误详情: ${error.toString()}');
        },
        onStatus: (status) {
          debugPrint('[VoiceAssistant] 📊 Speech recognition status: $status');
        },
      );
      
      debugPrint('[VoiceAssistant] 语音识别初始化结果: $speechAvailable');
      
      if (!speechAvailable) {
        debugPrint('[VoiceAssistant] ❌ Speech recognition not available');
        debugPrint('[VoiceAssistant] 可能的原因: 设备不支持、权限未授予、服务不可用');
        debugPrint('[VoiceAssistant] 设置初始化失败标志，防止重复尝试');
        _initializationFailed = true;
        return false;
      }
      
      debugPrint('[VoiceAssistant] 语音识别初始化成功，开始初始化TTS...');
      
      // 初始化TTS
      await _tts.setLanguage("en-US"); // English
      debugPrint('[VoiceAssistant] TTS 语言设置为: en-US');
      
      await _tts.setSpeechRate(0.5);   // 语速（0.0-1.0）
      await _tts.setVolume(1.0);       // 音量（0.0-1.0）
      await _tts.setPitch(1.0);        // 音调（0.5-2.0）
      debugPrint('[VoiceAssistant] TTS 参数设置完成 (语速: 0.5, 音量: 1.0, 音调: 1.0)');
      
      // 设置TTS回调
      _tts.setCompletionHandler(() {
        _isSpeaking = false;
        debugPrint('[VoiceAssistant] ✅ TTS completed');
      });
      
      _tts.setErrorHandler((msg) {
        _isSpeaking = false;
        debugPrint('[VoiceAssistant] ⚠️ TTS error: $msg');
      });
      
      _isInitialized = true;
      _initializationFailed = false; // 初始化成功，清除失败标志
      debugPrint('[VoiceAssistant] ✅ 初始化成功！_isInitialized = true');
      debugPrint('[VoiceAssistant] ===== initialize() 完成 =====');
      return true;
    } catch (e, stackTrace) {
      debugPrint('[VoiceAssistant] ❌ 初始化异常: $e');
      debugPrint('[VoiceAssistant] 异常类型: ${e.runtimeType}');
      debugPrint('[VoiceAssistant] 堆栈跟踪:');
      debugPrint(stackTrace.toString());
      
      // 标记初始化失败，防止无限循环
      _initializationFailed = true;
      debugPrint('[VoiceAssistant] 设置初始化失败标志，防止重复尝试');
      debugPrint('[VoiceAssistant] ===== initialize() 失败 =====');
      return false;
    }
  }
  
  /// Start listening for voice commands
  Future<void> startListening({
    required Function(String recognizedText) onResult,
    Function(String error)? onError,
  }) async {
    debugPrint('[VoiceAssistant] ===== startListening() 开始 =====');
    debugPrint('[VoiceAssistant] 当前状态: _isInitialized=$_isInitialized, _isListening=$_isListening');
    
    if (!_isInitialized) {
      debugPrint('[VoiceAssistant] 未初始化，尝试初始化...');
      final initialized = await initialize();
      debugPrint('[VoiceAssistant] 初始化结果: $initialized');
      
      if (!initialized) {
        debugPrint('[VoiceAssistant] ❌ 初始化失败，调用 onError');
        debugPrint('[VoiceAssistant] ===== startListening() 失败 =====');
        onError?.call('Voice assistant not initialized');
        return;
      }
      debugPrint('[VoiceAssistant] ✅ 初始化成功');
    }
    
    if (_isListening) {
      debugPrint('[VoiceAssistant] ⚠️ 已经在监听中，直接返回');
      debugPrint('[VoiceAssistant] ===== startListening() 跳过 =====');
      return;
    }
    
    debugPrint('[VoiceAssistant] 保存回调函数...');
    // 保存回调函数，用于恢复监听
    _savedOnResult = onResult;
    _savedOnError = onError;
    
    try {
      debugPrint('[VoiceAssistant] 调用 _speech.listen()...');
      debugPrint('[VoiceAssistant] 监听参数: listenFor=30s, pauseFor=3s, localeId=en_US');
      
      await _speech.listen(
        onResult: (result) {
          debugPrint('[VoiceAssistant] 📝 收到识别结果: finalResult=${result.finalResult}, recognizedWords="${result.recognizedWords}"');
          if (result.finalResult) {
            _isListening = false;
            debugPrint('[VoiceAssistant] 识别完成，_isListening 设为 false');
            final text = result.recognizedWords.trim();
            if (text.isNotEmpty) {
              debugPrint('[VoiceAssistant] ✅ 识别到文本: "$text"');
              onResult(text);
            } else {
              debugPrint('[VoiceAssistant] ⚠️ 识别文本为空，忽略');
            }
          } else {
            debugPrint('[VoiceAssistant] ⏳ 中间结果，继续监听...');
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        localeId: "en_US", // English recognition
      );
      
      _isListening = true;
      debugPrint('[VoiceAssistant] ✅ 监听启动成功，_isListening = true');
      debugPrint('[VoiceAssistant] ===== startListening() 成功 =====');
    } catch (e, stackTrace) {
      _isListening = false;
      debugPrint('[VoiceAssistant] ❌ 启动监听异常: $e');
      debugPrint('[VoiceAssistant] 异常类型: ${e.runtimeType}');
      debugPrint('[VoiceAssistant] 堆栈跟踪:');
      debugPrint(stackTrace.toString());
      debugPrint('[VoiceAssistant] ===== startListening() 异常 =====');
      onError?.call('Failed to start listening: $e');
    }
  }
  
  /// Stop listening
  void stopListening() {
    if (_isListening) {
      _speech.stop();
      _isListening = false;
      _wasListeningBeforePause = false;
      _savedOnResult = null;
      _savedOnError = null;
      debugPrint('[VoiceAssistant] Stopped listening');
    }
  }
  
  /// Pause listening (for smart switching during gesture control)
  void pauseListening() {
    if (_isListening) {
      _wasListeningBeforePause = true;
      _speech.stop();
      _isListening = false;
      debugPrint('[VoiceAssistant] Paused listening (will resume later)');
    }
  }
  
  /// Resume listening (for smart switching after gesture control ends)
  Future<void> resumeListening() async {
    if (_wasListeningBeforePause && _savedOnResult != null) {
      _wasListeningBeforePause = false;
      await startListening(
        onResult: _savedOnResult!,
        onError: _savedOnError,
      );
      debugPrint('[VoiceAssistant] Resumed listening');
    }
  }
  
  /// Recognize command type
  VoiceCommandType recognizeCommand(String text) {
    final normalizedText = text.toLowerCase().trim();
    
    // Check for jump to step command (e.g., "step 3", "go to step 3")
    final stepNumberMatch = RegExp(r'(?:step|go to step|jump to step)\s*(\d+)', caseSensitive: false)
        .firstMatch(normalizedText);
    if (stepNumberMatch != null) {
      return VoiceCommandType.jumpToStep;
    }
    
    // Match other commands
    for (final entry in _commandKeywords.entries) {
      for (final keyword in entry.value) {
        if (normalizedText.contains(keyword.toLowerCase())) {
          return entry.key;
        }
      }
    }
    
    return VoiceCommandType.unknown;
  }
  
  /// Extract step number from command text (for jump command)
  int? extractStepNumber(String text) {
    final match = RegExp(r'(?:step|go to step|jump to step)\s*(\d+)', caseSensitive: false)
        .firstMatch(text.toLowerCase());
    if (match != null) {
      return int.tryParse(match.group(1) ?? '');
    }
    return null;
  }
  
  /// Speak step content
  Future<void> speakStep(RecipeStepModel step) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return;
    }
    
    try {
      String text = 'Step ${step.stepNumber}: ${step.instruction}';
      if (step.stepTimeMin > 0) {
        text += ', approximately ${step.stepTimeMin} minutes';
      }
      
      _isSpeaking = true;
      await _tts.speak(text);
      debugPrint('[VoiceAssistant] Speaking: $text');
    } catch (e) {
      _isSpeaking = false;
      debugPrint('[VoiceAssistant] Speak error: $e');
    }
  }
  
  /// Speak text
  Future<void> speak(String text) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return;
    }
    
    try {
      _isSpeaking = true;
      await _tts.speak(text);
      debugPrint('[VoiceAssistant] Speaking: $text');
    } catch (e) {
      _isSpeaking = false;
      debugPrint('[VoiceAssistant] Speak error: $e');
    }
  }
  
  /// Stop speaking
  Future<void> stopSpeaking() async {
    if (_isSpeaking) {
      await _tts.stop();
      _isSpeaking = false;
      debugPrint('[VoiceAssistant] Stopped speaking');
    }
  }
  
  /// Get help text
  String getHelpText() {
    return 'Available voice commands: next step, previous step, repeat, start timer, pause timer, resume timer, stop timer, done, next dish, previous dish, current step, time left, ingredients, exit voice, help';
  }
  
  /// Whether listening
  bool get isListening => _isListening;
  
  /// Whether speaking
  bool get isSpeaking => _isSpeaking;
  
  /// Whether initialized
  bool get isInitialized => _isInitialized;
  
  /// Reset initialization failure flag (allow retry)
  void resetInitializationState() {
    debugPrint('[VoiceAssistant] 重置初始化状态');
    _initializationFailed = false;
    _isInitialized = false;
  }
  
  /// Whether initialization failed
  bool get isInitializationFailed => _initializationFailed;
  
  /// Cleanup resources
  void dispose() {
    stopListening();
    stopSpeaking();
    _speech.cancel();
    _isInitialized = false;
    _initializationFailed = false; // 清理时重置失败标志
  }
}
