// lib/services/recipe_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:personal_sous_chef/config/api_config.dart';
import 'package:personal_sous_chef/models/recipe_models.dart';
import 'package:personal_sous_chef/services/auth_service.dart';

class RecipeApiService {
  static Future<List<RecipeMenuModel>> generateMenus(
    Map<String, dynamic>? filter, {
    int? householdId,
  }) async {
    // 使用传入的householdId或从filter中获取
    final hId = householdId ?? filter?['householdId'];
    final url = Uri.parse('${ApiConfig.recipeBaseUrl}/api/ai/generate-menus');

    final body = _buildRequestBody(filter);
    final payload = jsonEncode(body);

    // Debug prints to inspect outgoing request
    print('[RecipeApi] POST $url');
    print('[RecipeApi] headers: {Content-Type: application/json}');
    print('[RecipeApi] body: $payload');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: payload,
    );

    print(
        '[RecipeApi] resp ${response.statusCode}: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to generate recipes: ${response.statusCode} ${response.body}');
    }

    final data = jsonDecode(response.body);
    List<dynamic>? menusJson;
    
    // 处理Result<T>格式: {code: 200, msg: "...", data: [...]}
    if (data is Map && data.containsKey('code')) {
      final code = data['code'] as int;
      if (code != 200) {
        throw Exception(data['msg']?.toString() ?? 'Failed to generate menus');
      }
      final responseData = data['data'];
      if (responseData is List) {
        menusJson = responseData;
      } else if (responseData is Map && responseData['menus'] is List) {
        menusJson = responseData['menus'] as List;
      }
    } else if (data is List) {
      menusJson = data;
    } else if (data is Map && data['menus'] is List) {
      menusJson = data['menus'] as List;
    }
    
    if (menusJson == null) {
      throw Exception('Unexpected response format.');
    }

    return menusJson
        .map<RecipeMenuModel>((e) => RecipeMenuModel.fromJson(e))
        .toList();
  }

  static Map<String, dynamic> _buildRequestBody(Map<String, dynamic>? filter) {
    final f = filter ?? {};
    final diet = f['diet_preferences'] ?? {};
    final allergies = (diet['allergies'] as List?) ?? [];
    final avoid = (diet['avoid_ingredients'] as List?) ?? [];
    final cuisines = (diet['cuisine_preferences'] as List?) ?? [];
    final tastes = (diet['taste_preferences'] as List?) ?? [];

    final calorie = f['calorie_target'];
    Map<String, dynamic>? calorieTarget;
    if (calorie != null) {
      final numValue = calorie is num ? calorie.toDouble() : double.tryParse(calorie.toString());
      if (numValue != null) {
        calorieTarget = {
          'min_total_kcal': numValue,
          'max_total_kcal': numValue,
        };
      }
    }

    return {
      'inventory': f['inventory'] ?? [],
      'servings': f['servings'] ?? 1,
      'diet_preferences': {
        'allergies': allergies,
        'avoid_ingredients': avoid,
        'cuisine_preferences': cuisines,
        'taste_preferences': tastes,
      },
      'generation_settings': {
        'dish_count': f['dish_count'] ?? 1,
        'max_cooking_time_min': f['max_cooking_time_min'],
        'difficulty_target': f['difficulty_target'], // now can be list for multi-select
      },
      'calorie_target': calorieTarget,
      'cookers': f['cookers'] ?? [],
      'seasonings': f['seasonings'] ?? [],
    };
  }
}
