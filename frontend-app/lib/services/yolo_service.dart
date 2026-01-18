import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:personal_sous_chef/models/ingredient.dart';

class YoloService {
  Interpreter? _interpreter;
  static const int _inputSize = 640;

  // 🔥 这里的标签顺序必须严格对应 Python 截图中的 0-76
  final List<String> _labels = [
    'Apple',
    'Apricot',
    'Asparagus',
    'Bagel',
    'Banana',
    'Beef-Lean',
    'Beef-Medium',
    'Beef-Medium-Lean',
    'Beef-marbled',
    'Beef-marbled-A5',
    'Beetroot',
    'Blueberry',
    'Bok-Choy',
    'Broccoli',
    'Brown-rice',
    'Butter',
    'Cabbage',
    'Cantaloupe',
    'Carrot',
    'Cauliflower',
    'Cherry',
    'Chicken-Breast',
    'Chicken-Leg',
    'Chicken-Quater',
    'Chicken-Thigh',
    'Chicken-Wing',
    'Coconut',
    'Corn',
    'Crab',
    'Cucumbers',
    'Dragon-Fruit',
    'Eggplant',
    'Eggs',
    'Garlic',
    'Ginger',
    'Grape',
    'Green-Pepper',
    'Kale',
    'Kiwifruit',
    'Lemon',
    'Lettuce',
    'Lime',
    'Longan',
    'Lychee',
    'Mango',
    'Milk',
    'Millet',
    'Minced-Meat',
    'Mussels',
    'Oats',
    'Orange',
    'Papaya',
    'Pasta',
    'Peach',
    'Pear',
    'Persimmon',
    'Pineapple',
    'PomoGranate',
    'Pork',
    'Potato',
    'Pumpkin',
    'Radish',
    'Red-Pepper',
    'Salmon',
    'Sausage',
    'Sea-Bass',
    'Sesame-Seeds',
    'Spanich',
    'Spring-Onion',
    'Squid',
    'Strawberry',
    'Sweet-Potato',
    'Tomato',
    'Tuna',
    'Watermelon',
    'White-Rice',
    'Zucchini',
  ];

  // 计算两个框的 IoU (交并比)
  // box 格式假设为: [x, y, w, h, score, classIndex]
  double calculateIoU(List<double> boxA, List<double> boxB) {
    // 1. 确定重叠区域 (Intersection) 的坐标
    // 注意：boxA[0] 是中心点 x，还是左上角 x，取决于你之前的 _postprocess 怎么写的。
    // 假设你之前的代码已经转成了 [x_min, y_min, x_max, y_max] 格式会更好算。
    // 这里我们假设传入的是 [x_min, y_min, width, height]

    double xA = max(boxA[0], boxB[0]);
    double yA = max(boxA[1], boxB[1]);
    double xB = min(boxA[0] + boxA[2], boxB[0] + boxB[2]);
    double yB = min(boxA[1] + boxA[3], boxB[1] + boxB[3]);

    // 2. 计算重叠面积
    double interArea = max(0, xB - xA) * max(0, yB - yA);

    // 3. 计算两个框各自的面积
    double boxAArea = boxA[2] * boxA[3];
    double boxBArea = boxB[2] * boxB[3];

    // 4. 计算 IoU
    double iou = interArea / (boxAArea + boxBArea - interArea);
    return iou;
  }

  List<Map<String, dynamic>> nonMaxSuppression(
    List<Map<String, dynamic>> boxes,
    double iouThreshold,
  ) {
    // 1. 如果没有框，直接返回
    if (boxes.isEmpty) return [];

    // 2. 按分数从高到低排序
    boxes.sort((a, b) => b['score'].compareTo(a['score']));

    List<Map<String, dynamic>> selectedBoxes = [];

    // 3. 循环筛选
    while (boxes.isNotEmpty) {
      // 拿下分数最高的那个 (current)
      var current = boxes.removeAt(0);
      selectedBoxes.add(current);

      // 拿着 current 跟剩下所有的 box 比
      boxes.removeWhere((otherBox) {
        // 注意：这里需要你把 map 里的 x,y,w,h 取出来传给 calculateIoU
        List<double> boxA = [
          current['x'],
          current['y'],
          current['w'],
          current['h'],
        ];
        List<double> boxB = [
          otherBox['x'],
          otherBox['y'],
          otherBox['w'],
          otherBox['h'],
        ];

        double iou = calculateIoU(boxA, boxB);

        // 如果重叠度大于阈值 (比如 0.45)，就删掉 (返回 true 代表删除)
        return iou > iouThreshold;
      });
    }

    return selectedBoxes;
  }

  Future<void> loadModel() async {
    if (_interpreter != null) return;
    try {
      // 加载 TFLite 模型
      final modelPath = 'assets/models/best.tflite';
      
      // TFLite 需要从 assets 复制到本地文件系统
      final ByteData data = await rootBundle.load(modelPath);
      final bytes = data.buffer.asUint8List();
      
      // 创建临时文件
      final tempDir = await Directory.systemTemp.createTemp('tflite_models');
      final modelFile = File('${tempDir.path}/best.tflite');
      await modelFile.writeAsBytes(bytes);
      
      // 加载模型
      _interpreter = Interpreter.fromFile(modelFile);
      
      // 打印模型信息
      final inputTensors = _interpreter!.getInputTensors();
      final outputTensors = _interpreter!.getOutputTensors();
      print("✅ TFLite Model loaded. Labels count: ${_labels.length}");
      print("   输入: ${inputTensors.map((t) => t.shape).toList()}");
      print("   输出: ${outputTensors.map((t) => t.shape).toList()}");
    } catch (e) {
      print("❌ Error loading TFLite model: $e");
      rethrow;
    }
  }

  Future<List<Ingredient>> analyzeImage(String imagePath) async {
    if (_interpreter == null) await loadModel();

    // A. 读取图片
    final imageFile = File(imagePath);
    final img.Image? originalImage = img.decodeImage(
      await imageFile.readAsBytes(),
    );
    if (originalImage == null) return [];

    // B. 预处理
    final inputData = _preprocess(originalImage);

    // C. 推理 - 使用 TFLite
    try {
      // 获取输出形状
      final outputTensors = _interpreter!.getOutputTensors();
      
      // 准备输出缓冲区
      final outputShape = outputTensors[0].shape;
      
      // 根据输出形状创建输出缓冲区
      // TFLite 需要一维数组，形状由解释器处理
      final totalSize = outputShape.reduce((a, b) => a * b);
      final outputBuffer = List<double>.generate(totalSize, (_) => 0.0);
      
      // 执行推理
      _interpreter!.run(inputData, outputBuffer);
      
      // D. 后处理
      // 将输出转换为 List<List<List<double>>> 格式
      // TFLite 输出是扁平数组，需要 reshape 为 [1, 81, 8400] 格式
      final rawOutput = _reshapeOutput(outputBuffer, outputShape);
      
      return _postprocess(rawOutput, originalImage.width, originalImage.height);
    } catch (e) {
      print("❌ TFLite inference error: $e");
      return [];
    }
  }
  
  /// 重塑输出数组
  List<List<List<double>>> _reshapeOutput(dynamic output, List<int> shape) {
    if (shape.length != 3) {
      throw Exception("Expected 3D output shape, got ${shape.length}D");
    }
    
    final batch = shape[0];
    final channels = shape[1];
    final anchors = shape[2];
    
    return List.generate(batch, (b) {
      return List.generate(channels, (c) {
        return List.generate(anchors, (a) {
          final index = b * channels * anchors + c * anchors + a;
          if (output is List) {
            return output[index].toDouble();
          }
          return 0.0;
        });
      });
    });
  }

  /// 预处理图片为 TFLite 输入格式
  /// 返回格式: [1, 3, 640, 640] 的 Float32List
  Float32List _preprocess(img.Image image) {
    final resized = img.copyResize(
      image,
      width: _inputSize,
      height: _inputSize,
    );
    
    // TFLite 期望的格式通常是 [batch, height, width, channels] 或 [batch, channels, height, width]
    // YOLO 模型通常使用 NCHW 格式: [1, 3, 640, 640]
    final Float32List float32List = Float32List(
      1 * 3 * _inputSize * _inputSize,
    );

    for (int y = 0; y < _inputSize; y++) {
      for (int x = 0; x < _inputSize; x++) {
        final pixel = resized.getPixel(x, y);
        // NCHW 格式: [batch, channel, height, width]
        float32List[0 * 3 * _inputSize * _inputSize + 0 * _inputSize * _inputSize + y * _inputSize + x] =
            pixel.r / 255.0;
        float32List[0 * 3 * _inputSize * _inputSize + 1 * _inputSize * _inputSize + y * _inputSize + x] =
            pixel.g / 255.0;
        float32List[0 * 3 * _inputSize * _inputSize + 2 * _inputSize * _inputSize + y * _inputSize + x] =
            pixel.b / 255.0;
      }
    }
    
    return float32List;
  }

  // 修改后的后处理方法：支持计数 + NMS 去重
  List<Ingredient> _postprocess(
    List<List<List<double>>> output,
    int imgW,
    int imgH,
  ) {
    final data = output[0];
    final int dimensions = data.length;
    final int anchors = data[0].length;

    List<Map<String, dynamic>> rawBoxes = [];

    // 1. 解析所有预测框
    for (int i = 0; i < anchors; i++) {
      double maxScore = 0;
      int maxClassIndex = -1;

      // 找出该 anchor 中概率最高的类别
      for (int c = 4; c < dimensions; c++) {
        final score = data[c][i];
        if (score > maxScore) {
          maxScore = score;
          maxClassIndex = c - 4;
        }
      }

      // 阈值过滤
      if (maxScore > 0.35) {
        // 🔥 修复点：必须解析坐标！NMS 算法计算重叠需要用到它们
        final cx = data[0][i]; // 中心点 x
        final cy = data[1][i]; // 中心点 y
        final w = data[2][i]; // 宽
        final h = data[3][i]; // 高

        rawBoxes.add({
          'score': maxScore,
          'classIndex': maxClassIndex,
          // 将中心点坐标 (cx, cy) 转换为左上角坐标 (x, y)，并根据图片尺寸还原比例
          'x': (cx - w / 2) * (imgW / _inputSize),
          'y': (cy - h / 2) * (imgH / _inputSize),
          'w': w * (imgW / _inputSize),
          'h': h * (imgH / _inputSize),
        });
      }
    }

    // 2. 执行 NMS 去重 (现在 rawBoxes 里有坐标了，不会报错了)
    List<Map<String, dynamic>> cleanBoxes = nonMaxSuppression(rawBoxes, 0.45);

    // 3. 统计每个类别的数量
    Map<String, int> ingredientCounts = {};

    for (var box in cleanBoxes) {
      String labelName = _labels[box['classIndex']];
      if (ingredientCounts.containsKey(labelName)) {
        ingredientCounts[labelName] = ingredientCounts[labelName]! + 1;
      } else {
        ingredientCounts[labelName] = 1;
      }
    }

    // 4. 转换为 Ingredient 对象
    List<Ingredient> results = [];
    ingredientCounts.forEach((name, count) {
      results.add(
        Ingredient(
          name: name.replaceAll('-', ' '),
          expiryDate: DateTime.now().add(const Duration(days: 7)),
          quantity: count.toDouble(), // 🔥 转换为 double
          unit: 'pcs',
          imagePlaceholder: _getEmojiForLabel(name),
        ),
      );
    });

    return results;
  }

  // 简单的 Emoji 映射，为了展示好看
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
    if (label.contains('apple')) return '🍎';
    if (label.contains('banana')) return '🍌';
    if (label.contains('pear')) return '🍐';
    if (label.contains('orange') ||
        label.contains('lemon') ||
        label.contains('lime'))
      return '🍊';
    if (label.contains('grape')) return '🍇';
    if (label.contains('watermelon')) return '🍉';
    if (label.contains('strawberry')) return '🍓';
    if (label.contains('cherry')) return '🍒';
    if (label.contains('peach')) return '🍑';
    if (label.contains('pineapple')) return '🍍';
    if (label.contains('mango')) return '🥭';
    if (label.contains('tomato')) return '🍅';
    if (label.contains('potato')) return '🥔';
    if (label.contains('carrot')) return '🥕';
    if (label.contains('corn')) return '🌽';
    if (label.contains('broccoli') || label.contains('cauliflower'))
      return '🥦';
    if (label.contains('eggplant')) return '🍆';
    if (label.contains('pepper')) return '🫑';
    if (label.contains('cucumber') || label.contains('zucchini')) return '🥒';
    if (label.contains('cabbage') ||
        label.contains('lettuce') ||
        label.contains('kale') ||
        label.contains('spinach'))
      return '🥬';
    if (label.contains('onion') || label.contains('garlic')) return '🧅';
    if (label.contains('egg')) return '🥚';
    if (label.contains('bread') || label.contains('bagel')) return '🥯';
    if (label.contains('rice')) return '🍚';
    if (label.contains('noodle') || label.contains('pasta')) return '🍝';
    if (label.contains('milk')) return '🥛';
    if (label.contains('butter')) return '🧈';
    return '🥘'; // 默认图标
  }
}
