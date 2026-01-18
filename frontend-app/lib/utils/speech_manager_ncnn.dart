// lib/utils/speech_manager_ncnn.dart
// Sherpa-NCNN 离线语音识别管理器
// 注意：这是一个基于 FFI 的实现框架，需要编译 native 库

import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sound_stream/sound_stream.dart';
import 'package:personal_sous_chef/utils/sherpa_ncnn_bindings.dart';

/// Sherpa-NCNN 离线语音识别管理器
class SpeechManager {
  // TODO: 这些类型需要根据实际的 FFI 绑定定义
  Pointer<Void>? _recognizer;
  Pointer<Void>? _stream;
  final RecorderStream _recorder = RecorderStream();

  // 回调函数，把识别结果传给 UI
  Function(String)? onResult;
  Function(String)? onError;

  bool _isReady = false;
  bool _isListening = false;

  /// 1. 初始化：复制模型文件并创建识别器
  Future<void> init() async {
    try {
      debugPrint('[SpeechManager] ===== 开始初始化 (Sherpa-NCNN) =====');

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

      // 复制 NCNN 模型文件到本地目录
      debugPrint('[SpeechManager] 开始复制 NCNN 模型文件...');
      String tokensPath = await _copyAssetToLocal("assets/audios/tokens.txt");
      String encoderParamPath = await _copyAssetToLocal(
          "assets/audios/encoder_jit_trace-pnnx.ncnn.param");
      String encoderBinPath = await _copyAssetToLocal(
          "assets/audios/encoder_jit_trace-pnnx.ncnn.bin");
      String decoderParamPath = await _copyAssetToLocal(
          "assets/audios/decoder_jit_trace-pnnx.ncnn.param");
      String decoderBinPath = await _copyAssetToLocal(
          "assets/audios/decoder_jit_trace-pnnx.ncnn.bin");
      String joinerParamPath = await _copyAssetToLocal(
          "assets/audios/joiner_jit_trace-pnnx.ncnn.param");
      String joinerBinPath = await _copyAssetToLocal(
          "assets/audios/joiner_jit_trace-pnnx.ncnn.bin");
      debugPrint('[SpeechManager] ✅ 模型文件复制完成');

      // 初始化 native 库绑定
      debugPrint('[SpeechManager] 初始化 Sherpa-NCNN native 库绑定...');
      SherpaNcnnBindings.initBindings();
      debugPrint('[SpeechManager] ✅ Native 库绑定初始化成功');

      // TODO: 创建识别器
      // 这里需要根据实际的 FFI API 来实现
      // 示例代码结构：
      // final config = SherpaNcnnRecognizerConfig(
      //   tokensPath: tokensPath,
      //   encoderParamPath: encoderParamPath,
      //   encoderBinPath: encoderBinPath,
      //   decoderParamPath: decoderParamPath,
      //   decoderBinPath: decoderBinPath,
      //   joinerParamPath: joinerParamPath,
      //   joinerBinPath: joinerBinPath,
      //   numThreads: 4,
      // );
      // _recognizer = _createRecognizer(config);
      // _stream = _createStream(_recognizer!);

      _isReady = true;
      debugPrint('[SpeechManager] ✅ 语音识别初始化完毕！(Sherpa-NCNN)');
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
      _isListening = true;
      debugPrint('[SpeechManager] ✅ 开始监听语音...');

      // 监听音频流
      _recorder.audioStream.listen(
        (data) {
          if (!_isListening) return;

          try {
            // data 是 Uint8List (PCM 16bit)，需要转换为 float
            final samples = Float32List(data.length ~/ 2);
            for (int i = 0; i < data.length; i += 2) {
              int sample = data[i] | (data[i + 1] << 8);
              if (sample > 32767) sample -= 65536;
              samples[i ~/ 2] = sample / 32768.0;
            }

            // TODO: 调用 NCNN 识别器进行识别
            // _stream?.acceptWaveform(samples: samples, sampleRate: 16000);
            // var result = _recognizer?.getResult(_stream!);
            // if (result != null && result.text.isNotEmpty) {
            //   debugPrint('[SpeechManager] 📝 识别结果: ${result.text}');
            //   onResult?.call(result.text);
            // }
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
      // TODO: 释放 stream
      // _stream?.free();
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
    // TODO: 释放 recognizer
    // _recognizer?.free();
    _recognizer = null;
    _isReady = false;
    debugPrint('[SpeechManager] ✅ 资源已清理');
  }

  /// 是否已初始化
  bool get isReady => _isReady;

  /// 是否正在监听
  bool get isListening => _isListening;
}

