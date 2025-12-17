// lib/services/cooking_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:personal_sous_chef/config/api_config.dart';

class CookingApiService {
  /// 开始烹饪：创建Session
  /// POST /api/cooking/start
  static Future<int> startCooking({
    required int householdId,
    required int initiatorId,
    int? dishId,
    Map<String, dynamic>? recipe,
    List<Map<String, dynamic>>? recipes, // 支持整个 Menu
    int? menuId,
  }) async {
    final url = Uri.parse('${ApiConfig.recipeBaseUrl}/api/cooking/start');
    final body = <String, dynamic>{
      'householdId': householdId,
      'initiatorId': initiatorId,
    };
    if (recipes != null && recipes.isNotEmpty) {
      // 支持多道菜（Menu）
      body['recipes'] = recipes;
      if (menuId != null) {
        body['menuId'] = menuId;
      }
    } else if (dishId != null) {
      body['dishId'] = dishId;
    } else if (recipe != null) {
      body['recipe'] = recipe;
    } else {
      throw Exception('Must provide either dishId, recipe, or recipes');
    }

    print('[CookingApi] POST $url');
    print('[CookingApi] body: ${jsonEncode(body)}');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    print('[CookingApi] POST resp ${response.statusCode}: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to start cooking: ${response.statusCode} ${response.body}');
    }

    final data = jsonDecode(response.body);
    // 处理Result<T>格式
    if (data is Map && data.containsKey('code')) {
      final code = data['code'] as int;
      if (code != 200) {
        throw Exception(data['msg']?.toString() ?? 'Failed to start cooking');
      }
      return (data['data'] as num).toInt();
    } else if (data is num) {
      return data.toInt();
    } else {
      throw Exception('Unexpected response format');
    }
  }

  /// 完成烹饪：保存快照，扣减库存，创建剩菜记录
  /// POST /api/cooking/finish
  static Future<Map<String, dynamic>> finishCooking({
    required int sessionId,
    required List<Map<String, dynamic>> finalIngredients,
    required Map<String, dynamic> totalNutrition,
    List<int>? completedDishIds, // 已完成的菜品 ID 列表（可选）
    List<Map<String, dynamic>>? diners, // 用餐者信息（可选）
  }) async {
    final url = Uri.parse('${ApiConfig.recipeBaseUrl}/api/cooking/finish');
    final body = <String, dynamic>{
      'sessionId': sessionId,
      'finalIngredients': finalIngredients,
      'totalNutrition': totalNutrition,
    };
    if (completedDishIds != null && completedDishIds.isNotEmpty) {
      body['completedDishIds'] = completedDishIds;
    }
    if (diners != null && diners.isNotEmpty) {
      body['diners'] = diners;
    }

    print('[CookingApi] POST $url');
    print('[CookingApi] body: ${jsonEncode(body)}');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    print('[CookingApi] POST resp ${response.statusCode}: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to finish cooking: ${response.statusCode} ${response.body}');
    }

    final data = jsonDecode(response.body);
    // 处理Result<T>格式
    if (data is Map && data.containsKey('code')) {
      final code = data['code'] as int;
      if (code != 200) {
        throw Exception(data['msg']?.toString() ?? 'Failed to finish cooking');
      }
      return data['data'] as Map<String, dynamic>;
    } else {
      return data as Map<String, dynamic>;
    }
  }
}

