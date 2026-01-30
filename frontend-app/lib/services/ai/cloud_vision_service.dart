import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:personal_sous_chef/core/config/api_config.dart';
import 'package:personal_sous_chef/core/config/ingredient_icon_config.dart';
import 'package:personal_sous_chef/core/config/yolo_labels_config.dart';
import 'package:personal_sous_chef/data/models/ingredient.dart';

/// 云端视觉识别服务（Gemini）
/// 负责识别图片中的多食材、预估数量及单位，并返回结构化列表。
/// 与 [ReviewIngredientsPage] 的校验逻辑配合：自动匹配标准库 ID、自动纠正单位。
class CloudVisionService {
  static const String _modelId = 'gemini-2.5-flash';

  /// 发送图片到 Gemini 进行多食材识别。
  /// 返回识别到的食材列表，如果失败返回空列表。
  Future<List<Ingredient>> identifyIngredients(File imageFile) async {
    if (ApiConfig.geminiApiKey.isEmpty) {
      debugPrint('❌ Cloud AI Error: API Key is empty');
      return [];
    }

    try {
      final model = GenerativeModel(
        model: _modelId,
        apiKey: ApiConfig.geminiApiKey,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
        ),
      );

      final Uint8List imageBytes = await imageFile.readAsBytes();

      // 第一层防护：把标准食材表注入 Prompt，强制 LLM 做选择题
      final String validIngredientsString = yoloLabels.join(", ");

      final content = [
        Content.multi([
          TextPart(
            "You are a professional sous chef. Look at this ingredient image. "
            "Identify ALL food ingredients visible in the image. "
            "IMPORTANT: You must STRICTLY map the detected ingredients to the closest match in the following Standard Inventory List. "
            "Do NOT invent new names. Do NOT use plurals if the list uses singulars (e.g. use 'Grape' not 'Grapes'). "
            "If an ingredient is visible but not in the list, use the closest synonym (e.g. use 'Capsicum' for 'Chili', 'Grape' for 'Grapes'). "
            "Standard Inventory List: [$validIngredientsString]. "
            "For each ingredient, estimate the quantity and provide a suitable standard unit. "
            "STRICTLY follow these unit rules: "
            "1. Liquids (e.g., milk, juice, oil, yogurt) MUST use 'L' or 'ml'. DO NOT use 'pcs' for liquids. "
            "2. Countable items (e.g., apples, eggs, onions, peppers) MUST use 'pcs'. "
            "3. Bulk solids (e.g., meat, flour, rice, potatoes) SHOULD use 'kg' or 'g'. "
            "Return the result as a JSON list of objects. Each object must have keys: "
            "'name' (string, MUST be one of the Standard Inventory List above), "
            "'quantity' (number), "
            "'unit' (string). "
            "Example output: "
            "[{\"name\": \"Milk\", \"quantity\": 1, \"unit\": \"L\"}, {\"name\": \"Apple\", \"quantity\": 6, \"unit\": \"pcs\"}]",
          ),
          DataPart('image/jpeg', imageBytes),
        ]),
      ];

      final response = await model.generateContent(content);
      final text = response.text?.trim();
      debugPrint("☁️ Cloud AI Raw Response: $text");

      if (text == null || text.isEmpty) return [];

      // --- JSON 解析与容错处理 ---
      String jsonString = text;
      if (jsonString.startsWith('```json')) {
        jsonString = jsonString.replaceFirst('```json', '').replaceAll('```', '').trim();
      } else if (jsonString.startsWith('```')) {
        jsonString = jsonString.replaceFirst('```', '').replaceAll('```', '').trim();
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      final List<Ingredient> ingredients = [];

      for (var item in jsonList) {
        if (item is Map<String, dynamic>) {
          final name = item['name']?.toString() ?? 'Unknown';
          final iconPath = getIngredientIconPath(name) ?? defaultIngredientIconPath;
          ingredients.add(
            Ingredient(
              name: name.replaceAll('-', ' '),
              quantity: (item['quantity'] as num?)?.toDouble() ?? 1.0,
              unit: item['unit']?.toString() ?? 'pcs',
              expiryDate: DateTime.now().add(const Duration(days: 7)),
              imagePlaceholder: iconPath,
            ),
          );
        }
      }

      debugPrint("✅ Parsed ${ingredients.length} ingredients from Cloud.");
      return ingredients;
    } catch (e) {
      debugPrint('❌ Cloud AI Error: $e');
      return [];
    }
  }
}
