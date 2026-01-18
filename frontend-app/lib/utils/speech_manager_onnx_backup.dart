// lib/utils/speech_manager_onnx_backup.dart
// ⚠️ 这是旧的 ONNX 实现的备份文件
// ⚠️ 注意：此文件引用了已移除的包，仅作为参考
// ⚠️ 当前项目已切换到 sherpa-ncnn，请使用 speech_manager.dart
// ⚠️ 此文件包含多个 lint 错误，因为是备份文件，已添加 ignore 指令

// ignore_for_file: unused_import
// ignore_for_file: undefined_import
// ignore_for_file: undefined_class
// ignore_for_file: undefined_identifier

import 'dart:ffi'; // 用于 DynamicLibrary
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
// 以下导入已失效，因为包已移除
// import 'package:onnxruntime/onnxruntime.dart' as ort;
// import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sound_stream/sound_stream.dart';

/// Sherpa-onnx 离线语音识别管理器
class SpeechManager {
  sherpa.OnlineRecognizer? _recognizer;
  sherpa.OnlineStream? _stream;
  final RecorderStream _recorder = RecorderStream();

  // 回调函数，把识别结果传给 UI
  Function(String)? onResult;
  Function(String)? onError;

  bool _isReady = false;
  bool _isListening = false;

  /// 1. 初始化：复制模型文件并创建识别器
  Future<void> init() async {
    try {
      debugPrint('[SpeechManager] ===== 开始初始化 =====');

      // 申请麦克风权限
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        debugPrint('[SpeechManager] ❌ 麦克风权限被拒绝');
        onError?.call('Microphone permission denied');
        return;
      }
      debugPrint('[SpeechManager] ✅ 麦克风权限已授予');

      // 初始化录音流
      await _recorder.initialize();
      debugPrint('[SpeechManager] ✅ 录音流初始化完成');

      // 复制模型到本地目录 (这是 Flutter 使用 Native 库的关键一步)
      debugPrint('[SpeechManager] 开始复制模型文件...');
      String encoderPath = await _copyAssetToLocal(
          "assets/audios/encoder-epoch-99-avg-1.int8.onnx");
      String decoderPath = await _copyAssetToLocal(
          "assets/audios/decoder-epoch-99-avg-1.int8.onnx");
      String joinerPath = await _copyAssetToLocal(
          "assets/audios/joiner-epoch-99-avg-1.int8.onnx");
      String tokensPath = await _copyAssetToLocal("assets/audios/tokens.txt");
      debugPrint('[SpeechManager] ✅ 模型文件复制完成');

      // ================== 【预加载 ONNX Runtime 库】 ==================
      // 强制预加载 libonnxruntime.so，解决 "cannot locate symbol OrtGetApiBase" 错误
      // 这是因为在 Android 上，sherpa-onnx 依赖 ONNX Runtime，但系统不会自动加载依赖库
      if (Platform.isAndroid) {
        debugPrint('[SpeechManager] ================== 开始预加载 ONNX Runtime 库 ==================');
        
        bool preloadSuccess = false;
        
        // 方法1: 尝试直接加载标准库名
        try {
          debugPrint('[SpeechManager] 尝试方法1: 直接加载 libonnxruntime.so...');
          final lib = DynamicLibrary.open('libonnxruntime.so');
          debugPrint('[SpeechManager] ✅ 成功预加载 libonnxruntime.so (方法1: 直接加载)');
          debugPrint('[SpeechManager] 库句柄: $lib');
          
          // 【关键】调用 onnxruntime 包的函数，强制符号被使用和导出到全局符号表
          try {
            debugPrint('[SpeechManager] 强制初始化 onnxruntime 包以导出符号...');
            final _ = ort.OrtSessionOptions(); // 创建对象以触发库初始化和符号导出
            debugPrint('[SpeechManager] ✅ onnxruntime 包初始化成功，符号应已导出到全局符号表');
            preloadSuccess = true;
          } catch (ortError) {
            debugPrint('[SpeechManager] ⚠️ onnxruntime 包初始化失败: $ortError');
            // 即使失败也继续，因为库已经加载了
            preloadSuccess = true;
          }
        } catch (e1) {
          debugPrint('[SpeechManager] ⚠️ 方法1失败: $e1');
          debugPrint('[SpeechManager] 错误类型: ${e1.runtimeType}');
          
          // 方法2: 尝试通过初始化 onnxruntime 包来触发库加载
          try {
            debugPrint('[SpeechManager] 尝试方法2: 通过 onnxruntime 包触发加载...');
            // 创建一个最小的 session 选项，这会触发 onnxruntime 库的加载
            final _ = ort.OrtSessionOptions(); // 创建对象以触发库加载
            debugPrint('[SpeechManager] ✅ 成功通过 onnxruntime 包触发库加载 (方法2: 初始化包)');
            preloadSuccess = true;
          } catch (e2) {
            debugPrint('[SpeechManager] ⚠️ 方法2失败: $e2');
            debugPrint('[SpeechManager] 错误类型: ${e2.runtimeType}');
            
            // 方法3: 尝试不同的库名格式（无 lib 前缀）
            try {
              debugPrint('[SpeechManager] 尝试方法3: 加载 onnxruntime (无前缀)...');
              final lib = DynamicLibrary.open('onnxruntime');
              debugPrint('[SpeechManager] ✅ 成功预加载 onnxruntime (方法3: 无前缀)');
              debugPrint('[SpeechManager] 库句柄: $lib');
              
              // 同样尝试初始化 onnxruntime 包
              try {
                final _ = ort.OrtSessionOptions(); // 创建对象以触发库初始化和符号导出
                debugPrint('[SpeechManager] ✅ onnxruntime 包初始化成功');
                preloadSuccess = true;
              } catch (ortError) {
                debugPrint('[SpeechManager] ⚠️ onnxruntime 包初始化失败: $ortError');
                preloadSuccess = true;
              }
            } catch (e3) {
              debugPrint('[SpeechManager] ⚠️ 方法3失败: $e3');
              debugPrint('[SpeechManager] 错误类型: ${e3.runtimeType}');
            }
          }
        }
        
        debugPrint('[SpeechManager] 预加载结果: ${preloadSuccess ? "✅ 成功" : "❌ 失败"}');
        debugPrint('[SpeechManager] ================== 预加载结束 ==================');
        
        if (!preloadSuccess) {
          debugPrint('[SpeechManager] ⚠️ 所有预加载方法都失败，继续尝试初始化（可能 MainActivity 已预加载）');
          debugPrint('[SpeechManager] 如果后续仍然失败，请检查 Android logcat 中 MainActivity 的预加载日志');
        }
        
        // 等待一小段时间，确保库加载完成并符号表更新
        debugPrint('[SpeechManager] 等待 200ms 以确保库加载完成和符号表更新...');
        await Future.delayed(const Duration(milliseconds: 200));
        debugPrint('[SpeechManager] 等待完成，继续初始化');
      }
      // ================== 【预加载代码结束】 ==================

      // 配置 Sherpa - 适配 v1.10.0+ / v1.12.x API
      // 在调用 initBindings 之前，尝试手动预加载 sherpa 库以确保依赖已解决
      if (Platform.isAndroid) {
        try {
          debugPrint('[SpeechManager] 尝试手动预加载 libsherpa-onnx-c-api.so...');
          // 确保 onnxruntime 已加载并通过包初始化
          try {
            final _ = ort.OrtSessionOptions();
            debugPrint('[SpeechManager] ✅ onnxruntime 符号已可用');
          } catch (e) {
            debugPrint('[SpeechManager] ⚠️ onnxruntime 符号检查失败: $e');
          }
          
          // 尝试手动加载 sherpa 库（如果还没加载的话）
          try {
            DynamicLibrary.open('libsherpa-onnx-c-api.so');
            debugPrint('[SpeechManager] ✅ 手动预加载 libsherpa-onnx-c-api.so 成功');
          } catch (e) {
            // 如果已经加载或加载失败，继续（initBindings 会处理）
            debugPrint('[SpeechManager] ℹ️ libsherpa-onnx-c-api.so 加载状态: $e');
          }
          
          // 再次等待符号表更新
          await Future.delayed(const Duration(milliseconds: 100));
        } catch (e) {
          debugPrint('[SpeechManager] ⚠️ 预初始化失败: $e');
        }
      }
      
      // 0. 【关键】先初始化底层绑定 (新版本必需)
      debugPrint('[SpeechManager] 开始调用 sherpa.initBindings()...');
      sherpa.initBindings();

      // 1. 配置 Transducer 模型 (仅包含模型文件路径)
      final transducerConfig = sherpa.OnlineTransducerModelConfig(
        encoder: encoderPath,
        decoder: decoderPath,
        joiner: joinerPath,
      );

      // 2. 配置整体模型参数 (tokens 和 modelType 移到了这里)
      final modelConfig = sherpa.OnlineModelConfig(
        transducer: transducerConfig,
        tokens: tokensPath,       // <--- 变化点：tokens 在这里
        numThreads: 1,
        modelType: "zipformer",   // <--- 变化点：明确指定模型类型
        debug: true,              // 调试模式，发布时可关掉
      );

      // 3. 配置识别器 (Recognizer)
      // 注意：如果 featConfig 参数不存在，可能需要使用其他方式配置采样率
      final config = sherpa.OnlineRecognizerConfig(
        model: modelConfig,
        // featConfig 可能在新版本中已移除或改名，先注释掉
        // featConfig: sherpa.FeatureConfig(
        //   sampleRate: 16000,
        //   featureDim: 80,
        // ),
        enableEndpoint: true,     // 启用自动断句
        rule1MinTrailingSilence: 2.4,
      );

      // 4. 实例化
      _recognizer = sherpa.OnlineRecognizer(config);
      _stream = _recognizer!.createStream();
      _isReady = true;
      debugPrint('[SpeechManager] ✅ 语音识别初始化完毕！(API v1.12适配版)');
    } catch (e, stackTrace) {
      debugPrint('[SpeechManager] ❌ 初始化异常: $e');
      debugPrint('[SpeechManager] 堆栈跟踪: $stackTrace');
      _isReady = false;
      onError?.call('Initialization failed: $e');
    }
  }

  /// 2. 开始识别
  void startListening() {
    if (!_isReady) {
      debugPrint('[SpeechManager] ⚠️ 未初始化，无法开始监听');
      onError?.call('Speech manager not initialized');
      return;
    }

    if (_isListening) {
      debugPrint('[SpeechManager] ⚠️ 已经在监听中');
      return;
    }

    try {
      // _stream 已在 init() 时创建，这里不需要重新创建
      if (_stream == null) {
        _stream = _recognizer?.createStream();
      }
      _isListening = true;
      debugPrint('[SpeechManager] ✅ 开始监听语音...');

      // 监听音频流
      _recorder.audioStream.listen(
        (data) {
          if (!_isListening) return;

          try {
            // data 是 Uint8List (PCM 16bit)，Sherpa 需要 Float List
            // 将 int16 转换为 float 并归一化 (-1.0 到 1.0)
            final samples = Float32List(data.length ~/ 2);
            for (int i = 0; i < data.length; i += 2) {
              // 小端序读取 int16
              int sample = data[i] | (data[i + 1] << 8);
              if (sample > 32767) sample -= 65536; // 处理符号位
              samples[i ~/ 2] = sample / 32768.0;
            }

            // 喂给识别器
            _stream?.acceptWaveform(samples: samples, sampleRate: 16000);

            // 解码并获取结果
            while (_recognizer?.isReady(_stream!) ?? false) {
              _recognizer?.decode(_stream!);
            }

            var result = _recognizer?.getResult(_stream!);
            if (result != null && result.text.isNotEmpty) {
              debugPrint('[SpeechManager] 📝 识别结果: ${result.text}');
              // 回调结果
              onResult?.call(result.text);
            }
          } catch (e) {
            debugPrint('[SpeechManager] ⚠️ 处理音频流时出错: $e');
          }
        },
        onError: (error) {
          debugPrint('[SpeechManager] ❌ 音频流错误: $error');
          onError?.call('Audio stream error: $error');
        },
        cancelOnError: false,
      );

      _recorder.start();
    } catch (e, stackTrace) {
      _isListening = false;
      debugPrint('[SpeechManager] ❌ 启动监听异常: $e');
      debugPrint('[SpeechManager] 堆栈跟踪: $stackTrace');
      onError?.call('Failed to start listening: $e');
    }
  }

  /// 3. 停止识别
  void stopListening() {
    if (!_isListening) {
      return;
    }

    try {
      _recorder.stop();
      _stream?.free();
      _stream = null;
      _isListening = false;
      debugPrint('[SpeechManager] ✅ 已停止监听');
    } catch (e) {
      debugPrint('[SpeechManager] ⚠️ 停止监听时出错: $e');
    }
  }

  /// 辅助方法：将 Asset 复制到本地路径
  Future<String> _copyAssetToLocal(String assetPath) async {
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final filename = assetPath.split('/').last;
      final file = File('${docsDir.path}/$filename');

      if (!await file.exists()) {
        debugPrint('[SpeechManager] 复制文件: $assetPath -> ${file.path}');
        final data = await rootBundle.load(assetPath);
        final bytes = data.buffer.asUint8List();
        await file.writeAsBytes(bytes);
        debugPrint('[SpeechManager] ✅ 文件复制完成: ${file.path}');
      } else {
        debugPrint('[SpeechManager] 文件已存在，跳过复制: ${file.path}');
      }

      return file.path;
    } catch (e) {
      debugPrint('[SpeechManager] ❌ 复制文件失败: $assetPath, 错误: $e');
      rethrow;
    }
  }

  /// 清理资源
  void dispose() {
    stopListening();
    _recognizer = null;
    _isReady = false;
    debugPrint('[SpeechManager] ✅ 资源已清理');
  }

  /// 是否已初始化
  bool get isReady => _isReady;

  /// 是否正在监听
  bool get isListening => _isListening;
}

