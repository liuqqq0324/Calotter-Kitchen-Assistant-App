// lib/utils/sherpa_ncnn_bindings.dart
// Sherpa-NCNN FFI 绑定
// 注意：需要编译 native 库 libsherpa-ncnn-c-api.so

import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

/// Sherpa-NCNN FFI 绑定
class SherpaNcnnBindings {
  static DynamicLibrary? _dylib;
  static bool _initialized = false;

  /// 初始化 native 库绑定
  static void initBindings() {
    if (_initialized) {
      return;
    }

    try {
      String libName;
      if (Platform.isAndroid) {
        libName = 'libsherpa-ncnn-c-api.so';
      } else if (Platform.isIOS) {
        libName = 'libsherpa-ncnn-c-api.dylib';
      } else if (Platform.isLinux) {
        libName = 'libsherpa-ncnn-c-api.so';
      } else if (Platform.isWindows) {
        libName = 'sherpa-ncnn-c-api.dll';
      } else if (Platform.isMacOS) {
        libName = 'libsherpa-ncnn-c-api.dylib';
      } else {
        throw UnsupportedError('Platform not supported: ${Platform.operatingSystem}');
      }

      _dylib = DynamicLibrary.open(libName);
      _initialized = true;
      print('[SherpaNcnnBindings] ✅ Native 库加载成功: $libName');
    } catch (e) {
      throw Exception('Failed to load sherpa-ncnn native library: $e');
    }
  }

  static DynamicLibrary get dylib {
    if (!_initialized || _dylib == null) {
      throw StateError('Bindings not initialized. Call initBindings() first.');
    }
    return _dylib!;
  }
}

// ==================== FFI 函数类型定义 ====================
// 注意：这些类型定义需要根据实际的 C API 调整

/// 创建识别器
/// 返回: Pointer<Void> 识别器句柄
typedef CreateRecognizerNative = Pointer<Void> Function(
  Pointer<Utf8> tokens,
  Pointer<Utf8> encoderParam,
  Pointer<Utf8> encoderBin,
  Pointer<Utf8> decoderParam,
  Pointer<Utf8> decoderBin,
  Pointer<Utf8> joinerParam,
  Pointer<Utf8> joinerBin,
  Int32 numThreads,
);
typedef CreateRecognizerDart = Pointer<Void> Function(
  Pointer<Utf8> tokens,
  Pointer<Utf8> encoderParam,
  Pointer<Utf8> encoderBin,
  Pointer<Utf8> decoderParam,
  Pointer<Utf8> decoderBin,
  Pointer<Utf8> joinerParam,
  Pointer<Utf8> joinerBin,
  int numThreads,
);

/// 创建流
typedef CreateStreamNative = Pointer<Void> Function(Pointer<Void> recognizer);
typedef CreateStreamDart = Pointer<Void> Function(Pointer<Void> recognizer);

/// 接受音频波形数据
typedef AcceptWaveformNative = Void Function(
  Pointer<Void> stream,
  Pointer<Float> samples,
  Int32 n,
  Int32 sampleRate,
);
typedef AcceptWaveformDart = void Function(
  Pointer<Void> stream,
  Pointer<Float> samples,
  int n,
  int sampleRate,
);

/// 检查是否准备好解码
typedef IsReadyNative = Int32 Function(Pointer<Void> recognizer, Pointer<Void> stream);
typedef IsReadyDart = int Function(Pointer<Void> recognizer, Pointer<Void> stream);

/// 解码
typedef DecodeNative = Void Function(Pointer<Void> recognizer, Pointer<Void> stream);
typedef DecodeDart = void Function(Pointer<Void> recognizer, Pointer<Void> stream);

/// 获取识别结果文本
typedef GetResultNative = Pointer<Utf8> Function(Pointer<Void> recognizer, Pointer<Void> stream);
typedef GetResultDart = Pointer<Utf8> Function(Pointer<Void> recognizer, Pointer<Void> stream);

/// 重置流
typedef ResetNative = Void Function(Pointer<Void> recognizer, Pointer<Void> stream);
typedef ResetDart = void Function(Pointer<Void> recognizer, Pointer<Void> stream);

/// 释放识别器
typedef DestroyRecognizerNative = Void Function(Pointer<Void> recognizer);
typedef DestroyRecognizerDart = void Function(Pointer<Void> recognizer);

/// 释放流
typedef DestroyStreamNative = Void Function(Pointer<Void> stream);
typedef DestroyStreamDart = void Function(Pointer<Void> stream);

/// NCNN 识别器配置
class SherpaNcnnRecognizerConfig {
  final String tokensPath;
  final String encoderParamPath;
  final String encoderBinPath;
  final String decoderParamPath;
  final String decoderBinPath;
  final String joinerParamPath;
  final String joinerBinPath;
  final int numThreads;
  final bool enableEndpoint;
  final double rule1MinTrailingSilence;

  const SherpaNcnnRecognizerConfig({
    required this.tokensPath,
    required this.encoderParamPath,
    required this.encoderBinPath,
    required this.decoderParamPath,
    required this.decoderBinPath,
    required this.joinerParamPath,
    required this.joinerBinPath,
    this.numThreads = 4,
    this.enableEndpoint = true,
    this.rule1MinTrailingSilence = 2.4,
  });
}

/// NCNN 识别结果
class SherpaNcnnResult {
  final String text;
  final List<int> tokens;
  final List<double> timestamps;

  SherpaNcnnResult({
    required this.text,
    required this.tokens,
    required this.timestamps,
  });

  @override
  String toString() => 'SherpaNcnnResult(text: $text)';
}

