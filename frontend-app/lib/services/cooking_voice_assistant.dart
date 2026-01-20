// lib/services/cooking_voice_assistant.dart
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:personal_sous_chef/models/recipe_models.dart';

/// 语音命令类型枚举
enum VoiceCommandType {
  nextStep,        // 下一步
  previousStep,    // 上一步
  repeatStep,      // 重复当前步骤
  jumpToStep,      // 跳转到指定步骤
  startTimer,      // 开始计时
  pauseTimer,      // 暂停计时
  resumeTimer,     // 继续计时
  stopTimer,       // 停止计时
  completeStep,    // 完成步骤
  nextDish,        // 下一道菜
  previousDish,    // 上一道菜
  currentStepInfo, // 当前步骤信息
  timerStatus,     // 计时器状态
  ingredientsList, // 食材列表
  exitVoiceMode,   // 退出语音模式
  help,            // 帮助
  unknown,         // 未知命令
}

/// 语音助手服务类
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
  
  // 命令关键词映射（支持中英文）
  static const Map<VoiceCommandType, List<String>> _commandKeywords = {
    VoiceCommandType.nextStep: [
      '下一步', '下一个步骤', '下一个', '下一步骤', '继续',
      'next step', 'next', 'continue'
    ],
    VoiceCommandType.previousStep: [
      '上一步', '上一个步骤', '上一个', '上一步骤', '返回',
      'previous step', 'previous', 'back', 'last step'
    ],
    VoiceCommandType.repeatStep: [
      '重复', '再说一遍', '重复一遍', '再说一次', '重新说',
      'repeat', 'say again', 'repeat step', 'once more'
    ],
    VoiceCommandType.startTimer: [
      '开始计时', '启动计时', '开始计时器', '启动计时器', '计时开始',
      'start timer', 'start timing', 'begin timer'
    ],
    VoiceCommandType.pauseTimer: [
      '暂停计时', '暂停', '暂停计时器',
      'pause timer', 'pause', 'pause timing'
    ],
    VoiceCommandType.resumeTimer: [
      '继续计时', '恢复计时', '继续', '恢复',
      'resume timer', 'resume', 'continue timer'
    ],
    VoiceCommandType.stopTimer: [
      '停止计时', '停止', '停止计时器', '取消计时',
      'stop timer', 'stop', 'cancel timer'
    ],
    VoiceCommandType.completeStep: [
      '完成', '完成了', '步骤完成', '标记完成', '完成这一步',
      'done', 'complete', 'step done', 'mark done', 'finish'
    ],
    VoiceCommandType.nextDish: [
      '下一道菜', '下一个菜', '下一道', '下一道菜品',
      'next dish', 'next recipe'
    ],
    VoiceCommandType.previousDish: [
      '上一道菜', '上一个菜', '上一道', '上一道菜品',
      'previous dish', 'last dish', 'previous recipe'
    ],
    VoiceCommandType.currentStepInfo: [
      '当前步骤', '现在步骤', '这一步', '当前',
      'current step', 'this step', 'now'
    ],
    VoiceCommandType.timerStatus: [
      '剩余时间', '还剩多少时间', '时间', '计时器状态',
      'time left', 'remaining time', 'timer status'
    ],
    VoiceCommandType.ingredientsList: [
      '食材', '食材列表', '需要什么', '材料',
      'ingredients', 'ingredient list', 'what do I need'
    ],
    VoiceCommandType.exitVoiceMode: [
      '退出语音', '退出语音模式', '关闭语音', '关闭',
      'exit voice', 'exit', 'close voice mode', 'turn off'
    ],
    VoiceCommandType.help: [
      '帮助', '怎么用', '使用说明', '命令',
      'help', 'how to use', 'commands', 'what can I say'
    ],
  };
  
  /// 检查并请求麦克风权限
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
  
  /// 初始化语音助手
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
      await _tts.setLanguage("zh-CN"); // 中文
      debugPrint('[VoiceAssistant] TTS 语言设置为: zh-CN');
      
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
  
  /// 开始监听语音命令
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
        onError?.call('语音助手未初始化');
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
      debugPrint('[VoiceAssistant] 监听参数: listenFor=30s, pauseFor=3s, localeId=zh_CN');
      
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
        localeId: "zh_CN", // 中文识别
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
      onError?.call('开始监听失败: $e');
    }
  }
  
  /// 停止监听
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
  
  /// 暂停监听（用于手势控制时的智能切换）
  void pauseListening() {
    if (_isListening) {
      _wasListeningBeforePause = true;
      _speech.stop();
      _isListening = false;
      debugPrint('[VoiceAssistant] Paused listening (will resume later)');
    }
  }
  
  /// 恢复监听（用于手势控制结束后的智能切换）
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
  
  /// 识别命令类型
  VoiceCommandType recognizeCommand(String text) {
    final normalizedText = text.toLowerCase().trim();
    
    // 检查跳转到指定步骤的命令（例如："跳转到步骤3"、"第3步"）
    final stepNumberMatch = RegExp(r'(?:步骤|第|跳转到步骤|跳转|step)\s*(\d+)', caseSensitive: false)
        .firstMatch(normalizedText);
    if (stepNumberMatch != null) {
      return VoiceCommandType.jumpToStep;
    }
    
    // 匹配其他命令
    for (final entry in _commandKeywords.entries) {
      for (final keyword in entry.value) {
        if (normalizedText.contains(keyword.toLowerCase())) {
          return entry.key;
        }
      }
    }
    
    return VoiceCommandType.unknown;
  }
  
  /// 从命令文本中提取步骤编号（用于跳转命令）
  int? extractStepNumber(String text) {
    final match = RegExp(r'(?:步骤|第|跳转到步骤|跳转|step)\s*(\d+)', caseSensitive: false)
        .firstMatch(text.toLowerCase());
    if (match != null) {
      return int.tryParse(match.group(1) ?? '');
    }
    return null;
  }
  
  /// 语音读出步骤内容
  Future<void> speakStep(RecipeStepModel step) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return;
    }
    
    try {
      String text = '步骤${step.stepNumber}：${step.instruction}';
      if (step.stepTimeMin > 0) {
        text += '，大约需要${step.stepTimeMin}分钟';
      }
      
      _isSpeaking = true;
      await _tts.speak(text);
      debugPrint('[VoiceAssistant] Speaking: $text');
    } catch (e) {
      _isSpeaking = false;
      debugPrint('[VoiceAssistant] Speak error: $e');
    }
  }
  
  /// 语音读出文本
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
  
  /// 停止语音播放
  Future<void> stopSpeaking() async {
    if (_isSpeaking) {
      await _tts.stop();
      _isSpeaking = false;
      debugPrint('[VoiceAssistant] Stopped speaking');
    }
  }
  
  /// 获取帮助文本
  String getHelpText() {
    return '您可以使用的语音命令：下一步、上一步、重复、开始计时、暂停计时、继续计时、停止计时、完成、下一道菜、上一道菜、当前步骤、剩余时间、食材、退出语音、帮助';
  }
  
  /// 是否正在监听
  bool get isListening => _isListening;
  
  /// 是否正在说话
  bool get isSpeaking => _isSpeaking;
  
  /// 是否已初始化
  bool get isInitialized => _isInitialized;
  
  /// 重置初始化失败标志（允许重新尝试初始化）
  void resetInitializationState() {
    debugPrint('[VoiceAssistant] 重置初始化状态');
    _initializationFailed = false;
    _isInitialized = false;
  }
  
  /// 是否初始化失败
  bool get isInitializationFailed => _initializationFailed;
  
  /// 清理资源
  void dispose() {
    stopListening();
    stopSpeaking();
    _speech.cancel();
    _isInitialized = false;
    _initializationFailed = false; // 清理时重置失败标志
  }
}
