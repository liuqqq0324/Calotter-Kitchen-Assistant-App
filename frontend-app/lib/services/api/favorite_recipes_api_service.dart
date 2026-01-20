// lib/services/favorite_recipes_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:personal_sous_chef/core/config/api_config.dart';
import 'package:personal_sous_chef/data/models/recipe_models.dart';

class FavoriteRecipesApiService {
  /// Fetch favorite list and hydrate each item with its detail payload.
  static Future<List<RecipeModel>> fetchFavorites({
    required int householdId,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.recipeBaseUrl}/api/recipes/favorites?householdId=$householdId',
    );
    print('[FavoriteApi] GET $url');
    final listResp = await http.get(url);
    print(
      '[FavoriteApi] GET resp ${listResp.statusCode}: ${_preview(listResp.body)}',
    );
    if (listResp.statusCode != 200) {
      throw Exception(
        'Failed to load favorites: ${listResp.statusCode} ${listResp.body}',
      );
    }

    final data = jsonDecode(listResp.body);
    // 处理Result<T>格式
    List<dynamic>? recipesJson;
    if (data is Map && data.containsKey('code')) {
      final code = data['code'] as int;
      if (code != 200) {
        throw Exception(
          data['message']?.toString() ?? 'Failed to load favorites',
        );
      }
      final responseData = data['data'];
      recipesJson = responseData is List ? responseData : [];
    } else if (data is List) {
      recipesJson = data;
    } else {
      recipesJson = (data['recipes'] as List?) ?? [];
    }

    final result = <RecipeModel>[];

    // 后端返回的是Dish实体列表，需要转换为RecipeModel
    for (final item in recipesJson) {
      try {
        result.add(_dishToRecipeModel(item));
      } catch (e) {
        print('[FavoriteApi] Failed to parse dish: $e');
      }
    }
    return result;
  }

  /// 将Dish实体转换为RecipeModel
  static RecipeModel _dishToRecipeModel(Map<String, dynamic> dish) {
    // 解析ingredients - 直接使用 amountValue 和 amountUnit（不再解析字符串）
    final ingredientsJson = dish['ingredientSnapshots'] as List? ?? [];
    final ingredients = ingredientsJson.map((ing) {
      final name = ing['name']?.toString() ?? '';
      // 直接使用 amountValue 和 amountUnit
      final amountValue =
          (ing['amountValue'] ?? ing['amount_value'] ?? 0) is num
          ? (ing['amountValue'] ?? ing['amount_value']).toDouble()
          : 0.0;
      final amountUnit =
          ing['amountUnit']?.toString() ??
          ing['amount_unit']?.toString() ??
          'g';

      return {
        'name': name,
        'amount_value': amountValue,
        'amount_unit': amountUnit,
        'is_optional': false,
      };
    }).toList();

    // 解析steps
    final stepsJson = dish['steps'] as List? ?? [];
    final steps = stepsJson.map((step) {
      return {
        'step_number': step['stepNumber'] ?? step['step_number'] ?? 0,
        'instruction': step['instruction']?.toString() ?? '',
        'step_time_min': step['timeMin'] ?? step['step_time_min'] ?? 0,
      };
    }).toList();

    // 解析营养字段
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString());
    }

    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString());
    }

    return RecipeModel.fromJson({
      'id': dish['id']?.toString() ?? '',
      'title': dish['name']?.toString() ?? '',
      'short_description': dish['description']?.toString() ?? '',
      'servings': 1, // Dish实体中没有servings字段，使用默认值
      'cooking_time_min':
          dish['cookingTimeMinutes'] ?? dish['cookingTimeMinutes'] ?? 0,
      'difficulty': (dish['difficulty']?.toString() ?? 'medium').toLowerCase(),
      'total_calories_estimate': dish['totalCalories']?.toDouble() ?? 0.0,
      'ingredients': ingredients,
      'steps': steps,
      'emoji': '🍽️', // 默认emoji
      // 营养字段（跟着后端）
      'total_weight_gram': parseInt(
        dish['totalWeightGram'] ?? dish['total_weight_gram'],
      ),
      'total_calories': parseInt(
        dish['totalCalories'] ?? dish['total_calories'],
      ),
      'total_protein': parseDouble(
        dish['totalProtein'] ?? dish['total_protein'],
      ),
      'total_fat': parseDouble(dish['totalFat'] ?? dish['total_fat']),
      'total_carb': parseDouble(dish['totalCarb'] ?? dish['total_carb']),
      'total_fiber': parseDouble(dish['totalFiber'] ?? dish['total_fiber']),
    });
  }

  /// Add a recipe to favorites and return the saved recipe with server id.
  static Future<RecipeModel> addFavorite(
    RecipeModel recipe, {
    required int householdId,
    String source = 'generated_menu',
  }) async {
    final payload = _recipeToJson(recipe);
    final url = Uri.parse(
      '${ApiConfig.recipeBaseUrl}/api/recipes/favorite?householdId=$householdId',
    );
    print('[FavoriteApi] POST $url');
    print('[FavoriteApi] body: ${jsonEncode(payload)}');
    final resp = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    print('[FavoriteApi] POST resp ${resp.statusCode}: ${_preview(resp.body)}');
    if (resp.statusCode != 200 && resp.statusCode != 201) {
      throw Exception(
        'Failed to add favorite: ${resp.statusCode} ${resp.body}',
      );
    }
    final data = jsonDecode(resp.body);
    // 处理Result<T>格式
    Map<String, dynamic> dishData;
    if (data is Map && data.containsKey('code')) {
      final code = data['code'] as int;
      if (code != 200) {
        throw Exception(
          data['message']?.toString() ?? 'Failed to add favorite',
        );
      }
      dishData = data['data'] as Map<String, dynamic>;
    } else {
      dishData = data as Map<String, dynamic>;
    }

    return _dishToRecipeModel(dishData);
  }

  /// Remove a favorite by id (toggle off).
  static Future<void> removeFavorite(
    String recipeId, {
    required int householdId,
  }) async {
    // 后端使用toggle接口，需要传递完整的recipe信息
    // 这里我们需要先获取recipe详情，然后调用toggle
    throw UnimplementedError('Use toggleFavorite instead');
  }

  /// Toggle favorite (add or remove)
  static Future<RecipeModel?> toggleFavorite(
    RecipeModel recipe, {
    required int householdId,
  }) async {
    final payload = _recipeToJson(recipe);
    final url = Uri.parse(
      '${ApiConfig.recipeBaseUrl}/api/recipes/favorite?householdId=$householdId',
    );
    print('[FavoriteApi] POST (toggle) $url');
    print('[FavoriteApi] body: ${jsonEncode(payload)}');
    final resp = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    print('[FavoriteApi] POST resp ${resp.statusCode}: ${_preview(resp.body)}');
    if (resp.statusCode != 200) {
      throw Exception(
        'Failed to toggle favorite: ${resp.statusCode} ${resp.body}',
      );
    }
    final data = jsonDecode(resp.body);
    // 处理Result<T>格式
    Map<String, dynamic>? dishData;
    if (data is Map && data.containsKey('code')) {
      final code = data['code'] as int;
      if (code != 200) {
        throw Exception(
          data['message']?.toString() ?? 'Failed to toggle favorite',
        );
      }
      dishData = data['data'] as Map<String, dynamic>?;
    } else {
      dishData = data as Map<String, dynamic>?;
    }

    if (dishData == null) return null;

    // 检查是否还是收藏状态
    final isFavorite = dishData['favorite'] as bool? ?? false;
    if (!isFavorite) return null; // 已取消收藏

    return _dishToRecipeModel(dishData);
  }

  static Map<String, dynamic> _recipeToJson(RecipeModel recipe) {
    return {
      'title': recipe.title,
      'shortDescription': recipe.shortDescription,
      'servings': recipe.servings,
      'cookingTimeMin': recipe.cookingTimeMin,
      'difficulty': recipe.difficulty,
      'nutritionEstimate': {
        'calories': recipe.totalCaloriesEstimate,
        'proteinG': recipe.totalProtein ?? 0.0,
        'fatG': recipe.totalFat ?? 0.0,
        'carbsG': recipe.totalCarb ?? 0.0,
      },
      'ingredients': recipe.ingredients
          .map(
            (i) => {
              'name': i.name,
              'amountValue': i.amountValue,
              'amountUnit': i.amountUnit,
              'isOptional': i.isOptional,
              'sourceType': 'MANUAL_ADD', // 默认值
            },
          )
          .toList(),
      'steps': recipe.steps
          .map(
            (s) => {
              'stepNumber': s.stepNumber,
              'instruction': s.instruction,
              'stepTimeMin': s.stepTimeMin,
            },
          )
          .toList(),
    };
  }

  static String _preview(String body, {int max = 300}) {
    if (body.length <= max) return body;
    return '${body.substring(0, max)}...';
  }
}
