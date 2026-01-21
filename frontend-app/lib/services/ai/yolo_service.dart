import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:onnxruntime/onnxruntime.dart'; // ✅ 使用官方库
import 'package:personal_sous_chef/data/models/ingredient.dart';
import 'package:personal_sous_chef/core/config/yolo_labels_config.dart'; // ✅ 使用统一的标签配置

class YoloService {
  OrtSession? _session;

  // YOLOv8 标准输入尺寸 (与模型训练时保持一致)
  static const int _inputSize = 512;

  // 🔥 标签列表 (96个类别) - 从配置文件导入，确保与模型一致
  final List<String> _labels = yoloLabels;

  /// 1. 加载模型 (本地离线加载)
  Future<void> loadModel() async {
    if (_session != null) return;

    try {
      // ✅ 官方库初始化方式
      OrtEnv.instance.init();

      // ✅ 官方库不支持直接从 assets 路径加载，必须先读入内存
      final modelRaw = await rootBundle.load('assets/models/best.onnx');

      final sessionOptions = OrtSessionOptions();
      sessionOptions.setIntraOpNumThreads(2); // 设置线程数

      // 从 Buffer 创建会话
      _session = OrtSession.fromBuffer(
        modelRaw.buffer.asUint8List(),
        sessionOptions,
      );

      sessionOptions.release();

      print("✅ ONNX 本地模型加载成功！");
      print("   输入尺寸: ${_inputSize}x${_inputSize}");
      print("   标签数量: ${_labels.length}");
    } catch (e, stackTrace) {
      print("❌ 模型加载失败: $e");
      print("Stack trace: $stackTrace");
      rethrow;
    }
  }

  /// 2. 核心推理函数
  Future<List<Ingredient>> analyzeImage(String imagePath) async {
    if (_session == null) await loadModel();

    // A. 读取图片
    final File imageFile = File(imagePath);
    if (!await imageFile.exists()) return [];

    final img.Image? originalImage = img.decodeImage(
      await imageFile.readAsBytes(),
    );
    if (originalImage == null) return [];

    // B. 预处理 (转换为 ONNX 标准的 NCHW 格式)
    final Float32List inputFloats = _preprocessNCHW(originalImage);

    try {
      // ✅ C. 创建 Tensor (使用 OrtValueTensor)
      // 形状: [Batch, Channels, Height, Width] -> [1, 3, 640, 640]
      final inputOrt = OrtValueTensor.createTensorWithDataList(inputFloats, [
        1,
        3,
        _inputSize,
        _inputSize,
      ]);

      // D. 运行推理
      final inputs = {'images': inputOrt}; // YOLOv8 默认输入名为 'images'

      final runOptions = OrtRunOptions();

      final outputs = _session!.run(runOptions, inputs);

      // ✅ E. 获取输出数据 (官方库返回值结构处理)
      // outputs[0].value 在 Dart 插件中通常是一个嵌套列表
      // YOLOv8 输出: [1, 81, 8400] -> 我们取第一个 batch -> [81, 8400]
      // 类型通常是 List<List<List<double>>> 或 List<dynamic>
      final rawBatchOutput = (outputs[0]?.value as List)[0];

      // 这里的 rawBatchOutput 应该是一个 List<List<double>> (Channels x Anchors)
      // 如果报错类型转换错误，需要根据实际运行时类型调整，但通常如下：
      final List<List<double>> outputMatrix = (rawBatchOutput as List)
          .map((e) => (e as List).map((x) => x as double).toList())
          .toList();

      // 释放内存资源 (非常重要)
      inputOrt.release();
      runOptions.release();
      for (var element in outputs) {
        element?.release();
      }

      // F. 后处理
      return _postprocess(
        outputMatrix,
        originalImage.width,
        originalImage.height,
      );
    } catch (e, stackTrace) {
      print("❌ 推理过程出错: $e");
      print("Stack trace: $stackTrace");
      return [];
    }
  }

  /// 预处理：将图片转为 NCHW (Planar RGB) 格式
  Float32List _preprocessNCHW(img.Image image) {
    // 1. 强制调整大小
    final resized = img.copyResize(
      image,
      width: _inputSize,
      height: _inputSize,
    );

    final int pixelCount = _inputSize * _inputSize;
    final Float32List floatList = Float32List(3 * pixelCount);

    // 2. 填充数据 (R平面, G平面, B平面)
    for (int y = 0; y < _inputSize; y++) {
      for (int x = 0; x < _inputSize; x++) {
        final pixel = resized.getPixel(x, y);
        final int index = y * _inputSize + x;

        // 分离通道并归一化
        floatList[index] = pixel.r / 255.0; // R
        floatList[index + pixelCount] = pixel.g / 255.0; // G
        floatList[index + pixelCount * 2] = pixel.b / 255.0; // B
      }
    }

    return floatList;
  }

  /// 后处理：解析 YOLO 输出矩阵
  List<Ingredient> _postprocess(List<List<double>> output, int imgW, int imgH) {
    int channels = output.length; // 例如 81
    int anchors = output[0].length; // 例如 8400
    int nc = channels - 4; // 类别数

    print("📊 后处理: channels=$channels, anchors=$anchors, 类别数=$nc");

    List<Map<String, dynamic>> rawBoxes = [];

    // 1. 遍历所有 anchor (按列遍历)
    // 先检查一些样本数据的范围，用于调试
    if (anchors > 0) {
      final sampleScores = <double>[];
      for (int c = 0; c < min(nc, 10); c++) {
        for (int i = 0; i < min(100, anchors); i++) {
          sampleScores.add(output[4 + c][i]);
        }
      }
      if (sampleScores.isNotEmpty) {
        sampleScores.sort();
        print("📊 类别概率样本统计 (前10类，前100个anchor):");
        print("   最小值: ${sampleScores.first}");
        print("   最大值: ${sampleScores.last}");
        print("   中位数: ${sampleScores[sampleScores.length ~/ 2]}");
      }
    }

    for (int i = 0; i < anchors; i++) {
      double maxScore = 0;
      int maxClassIndex = -1;

      // 找出该框属于哪个类别 (从第4行开始是类别分)
      for (int c = 0; c < nc; c++) {
        double score = output[4 + c][i];
        if (score > maxScore) {
          maxScore = score;
          maxClassIndex = c;
        }
      }

      // 阈值过滤（根据测试结果，类别概率范围很小，需要降低阈值）
      // 测试显示类别概率范围：0.000001 到 0.172829，平均值 0.000026
      // 将阈值从 0.35 降低到 0.01 或更低
      if (maxScore > 0.01) {
        // 坐标是像素坐标，需要归一化
        double cx = output[0][i] / _inputSize; // 归一化
        double cy = output[1][i] / _inputSize;
        double w = output[2][i] / _inputSize;
        double h = output[3][i] / _inputSize;

        // 还原为原图坐标
        double x = (cx - w / 2) * imgW;
        double y = (cy - h / 2) * imgH;
        double width = w * imgW;
        double height = h * imgH;

        rawBoxes.add({
          'score': maxScore,
          'classIndex': maxClassIndex,
          'x': x,
          'y': y,
          'w': width,
          'h': height,
        });
      }
    }

    print("📊 检测到 ${rawBoxes.length} 个候选框（阈值过滤后）");

    // 2. NMS 去重
    List<Map<String, dynamic>> cleanBoxes = nonMaxSuppression(rawBoxes, 0.45);
    print("📊 NMS 后剩余 ${cleanBoxes.length} 个检测框");

    // 3. 统计并封装为 Ingredient
    Map<String, int> ingredientCounts = {};

    for (var box in cleanBoxes) {
      int idx = box['classIndex'] as int;

      // 安全检查：防止索引越界
      if (idx >= 0 && idx < _labels.length) {
        String name = _labels[idx];
        ingredientCounts[name] = (ingredientCounts[name] ?? 0) + 1;
      }
    }

    List<Ingredient> results = [];
    ingredientCounts.forEach((name, count) {
      results.add(
        Ingredient(
          name: name.replaceAll('-', ' '),
          expiryDate: DateTime.now().add(const Duration(days: 7)),
          quantity: count.toDouble(),
          unit: 'pcs',
          imagePlaceholder: _getEmojiForLabel(name),
        ),
      );
    });

    return results;
  }

  // --- NMS 算法 ---
  List<Map<String, dynamic>> nonMaxSuppression(
    List<Map<String, dynamic>> boxes,
    double iouThreshold,
  ) {
    if (boxes.isEmpty) return [];

    boxes.sort(
      (a, b) => (b['score'] as double).compareTo(a['score'] as double),
    );

    List<Map<String, dynamic>> selected = [];

    while (boxes.isNotEmpty) {
      var current = boxes.removeAt(0);
      selected.add(current);

      boxes.removeWhere((other) {
        return calculateIoU(
              [current['x'], current['y'], current['w'], current['h']],
              [other['x'], other['y'], other['w'], other['h']],
            ) >
            iouThreshold;
      });
    }

    return selected;
  }

  // --- IoU 计算 ---
  double calculateIoU(List<double> boxA, List<double> boxB) {
    double xA = max(boxA[0], boxB[0]);
    double yA = max(boxA[1], boxB[1]);
    double xB = min(boxA[0] + boxA[2], boxB[0] + boxB[2]);
    double yB = min(boxA[1] + boxA[3], boxB[1] + boxB[3]);

    double interArea = max(0, xB - xA) * max(0, yB - yA);
    double boxAArea = boxA[2] * boxA[3];
    double boxBArea = boxB[2] * boxB[3];

    return interArea / (boxAArea + boxBArea - interArea);
  }

  // --- Emoji 映射 ---
  String _getEmojiForLabel(String label) {
    label = label.toLowerCase();
    if (label.contains('beef') || label.contains('steak')) return '🥩';
    if (label.contains('chicken')) return '🍗';
    if (label.contains('pork') || label.contains('sausage')) return '🥓';
    if (label.contains('fish') ||
        label.contains('salmon') ||
        label.contains('bass') ||
        label.contains('tuna'))
      return '🐟';
    if (label.contains('crab') ||
        label.contains('mussels') ||
        label.contains('squid'))
      return '🦀';
    if (label.contains('lamb')) return '🐑';
    if (label.contains('apple')) return '🍎';
    if (label.contains('banana')) return '🍌';
    if (label.contains('pear')) return '🍐';
    if (label.contains('orange') ||
        label.contains('lemon') ||
        label.contains('lime') ||
        label.contains('mandarin'))
      return '🍊';
    if (label.contains('grape')) return '🍇';
    if (label.contains('watermelon')) return '🍉';
    if (label.contains('strawberry')) return '🍓';
    if (label.contains('cherry')) return '🍒';
    if (label.contains('peach')) return '🍑';
    if (label.contains('pineapple')) return '🍍';
    if (label.contains('mango')) return '🥭';
    if (label.contains('apricot')) return '🍑';
    if (label.contains('nectarine')) return '🍑';
    if (label.contains('guava')) return '🍈';
    if (label.contains('pomegranate')) return '🍎';
    if (label.contains('persimmon')) return '🍊';
    if (label.contains('lychee') || label.contains('longan')) return '🍒';
    if (label.contains('dragon-fruit')) return '🐉';
    if (label.contains('coconut')) return '🥥';
    if (label.contains('kiwifruit')) return '🥝';
    if (label.contains('papaya')) return '🍈';
    if (label.contains('tomato')) return '🍅';
    if (label.contains('potato') || label.contains('sweet-potato')) return '🥔';
    if (label.contains('carrot')) return '🥕';
    if (label.contains('corn')) return '🌽';
    if (label.contains('broccoli') || label.contains('cauliflower'))
      return '🥦';
    if (label.contains('eggplant')) return '🍆';
    if (label.contains('pepper') || label.contains('capsicum')) return '🫑';
    if (label.contains('cucumber') ||
        label.contains('zucchini') ||
        label.contains('courgette'))
      return '🥒';
    if (label.contains('cabbage') ||
        label.contains('lettuce') ||
        label.contains('kale') ||
        label.contains('spinach') ||
        label.contains('spanich') ||
        label.contains('bok-choy'))
      return '🥬';
    if (label.contains('onion') ||
        label.contains('garlic') ||
        label.contains('leek') ||
        label.contains('spring-onion'))
      return '🧅';
    if (label.contains('asparagus')) return '🥬';
    if (label.contains('celery')) return '🥬';
    if (label.contains('parsnip')) return '🥕';
    if (label.contains('radish')) return '🥕';
    if (label.contains('pumpkin')) return '🎃';
    if (label.contains('beetroot')) return '🥕';
    if (label.contains('mushroom')) return '🍄';
    if (label.contains('ginger')) return '🫚';
    if (label.contains('egg')) return '🥚';
    if (label.contains('bread') || label.contains('bagel')) return '🥯';
    if (label.contains('rice') ||
        label.contains('brown-rice') ||
        label.contains('white-rice'))
      return '🍚';
    if (label.contains('noodle') || label.contains('pasta')) return '🍝';
    if (label.contains('milk')) return '🥛';
    if (label.contains('butter')) return '🧈';
    if (label.contains('oats') || label.contains('millet')) return '🌾';
    if (label.contains('lentil') || label.contains('chickpea')) return '🫘';
    if (label.contains('sesame-seeds')) return '🫘';
    if (label.contains('avocado')) return '🥑';
    if (label.contains('blueberry') || label.contains('blackberry'))
      return '🫐';
    if (label.contains('cantaloupe')) return '🍈';
    return '🥘';
  }

  /// 释放资源
  void dispose() {
    _session?.release();
    _session = null;
    print("✅ YOLO 服务资源已释放");
  }
}
