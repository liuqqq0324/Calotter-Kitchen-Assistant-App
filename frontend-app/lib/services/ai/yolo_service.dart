import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_vision/flutter_vision.dart';
import 'package:image/image.dart' as img;
import 'package:personal_sous_chef/data/models/ingredient.dart';
import 'package:personal_sous_chef/core/config/ingredient_icon_config.dart';

/// YOLO 图像识别服务（TFLite + flutter_vision）
/// 标签顺序与 assets/models/label.txt 一致。
class YoloService {
  late FlutterVision _vision;
  bool _isLoaded = false;

  Future<void> loadModel() async {
    if (_isLoaded) return;
    _vision = FlutterVision();

    await _vision.loadYoloModel(
      labels: 'assets/models/label.txt',
      modelPath: 'assets/models/yolo.tflite',
      modelVersion: 'yolov8',
      numThreads: 2,
      useGpu: true,
      quantization: false,
    );
    _isLoaded = true;
    print("✅ TFLite YOLO 模型加载成功");
  }

  Future<List<Ingredient>> analyzeImage(String imagePath) async {
    if (!_isLoaded) await loadModel();

    final File imageFile = File(imagePath);
    if (!await imageFile.exists()) return [];

    final Uint8List imageBytes = await imageFile.readAsBytes();
    final img.Image? decoded = img.decodeImage(imageBytes);
    if (decoded == null) return [];

    final result = await _vision.yoloOnImage(
      bytesList: imageBytes,
      imageHeight: decoded.height,
      imageWidth: decoded.width,
      iouThreshold: 0.45,
      confThreshold: 0.65,
      classThreshold: 0.4,
    );

    if (result.isEmpty) return [];
    return _parseResults(result);
  }

  List<Ingredient> _parseResults(List<Map<String, dynamic>> yoloResults) {
    final Map<String, int> counts = {};

    for (var item in yoloResults) {
      final String label = item['tag'] as String? ?? '';
      if (label.isEmpty) continue;
      counts[label] = (counts[label] ?? 0) + 1;
    }

    final List<Ingredient> ingredients = [];
    counts.forEach((name, count) {
      final iconPath = getIngredientIconPath(name) ?? defaultIngredientIconPath;
      ingredients.add(
        Ingredient(
          name: name.replaceAll('-', ' '),
          quantity: count.toDouble(),
          unit: 'pcs',
          expiryDate: DateTime.now().add(const Duration(days: 7)),
          imagePlaceholder: iconPath,
        ),
      );
    });
    return ingredients;
  }

  Future<void> dispose() async {
    if (_isLoaded) {
      await _vision.closeYoloModel();
      _isLoaded = false;
      print("✅ YOLO 服务资源已释放");
    }
  }
}
