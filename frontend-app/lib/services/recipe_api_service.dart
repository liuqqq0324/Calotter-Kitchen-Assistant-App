// lib/services/recipe_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:personal_sous_chef/config/api_config.dart';
import 'package:personal_sous_chef/models/recipe_models.dart';

class RecipeApiService {
  static Future<List<RecipeMenuModel>> generateMenus(
    Map<String, dynamic>? filter,
  ) async {
    final url = Uri.parse('${ApiConfig.recipeBaseUrl}/api/recipes/generate');

    final body = _buildRequestBody(filter);

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to generate recipes: ${response.statusCode} ${response.body}');
    }

    final data = jsonDecode(response.body);
    List<dynamic>? menusJson;
    if (data is List) {
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
        'difficulty_target': f['difficulty_target'],
      },
      'calorie_target': calorieTarget,
      'cookers': f['cookers'] ?? [],
      'seasonings': f['seasonings'] ?? [],
    };
  }
}
