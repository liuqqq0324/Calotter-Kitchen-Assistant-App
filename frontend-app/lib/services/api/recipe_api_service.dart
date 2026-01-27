// lib/services/recipe_api_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:personal_sous_chef/core/config/api_config.dart';
import 'package:personal_sous_chef/data/models/recipe_models.dart';
import 'package:personal_sous_chef/services/business/auth_service.dart';
import 'package:personal_sous_chef/services/business/household_service.dart';

class RecipeApiService {
  /// 获取默认 Filter（基于用户的偏好和健康目标）
  static Future<Map<String, dynamic>> getDefaultFilter({
    int? householdId,
  }) async {
    final hId = householdId ?? await HouseholdService.getHouseholdId();
    if (hId == null) {
      throw Exception('householdId is required');
    }

    final url = Uri.parse(
      '${ApiConfig.recipeBaseUrl}/api/recipes/default-filter?householdId=$hId',
    );
    print('[RecipeApi] GET $url');

    final response = await http.get(url);
    print(
      '[RecipeApi] GET resp ${response.statusCode}: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}',
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to get default filter: ${response.statusCode} ${response.body}',
      );
    }

    final data = jsonDecode(response.body);
    Map<String, dynamic>? filterData;

    // 处理Result<T>格式
    if (data is Map && data.containsKey('code')) {
      final code = data['code'] as int;
      if (code != 200) {
        throw Exception(
          data['message']?.toString() ?? 'Failed to get default filter',
        );
      }
      filterData = data['data'] as Map<String, dynamic>?;
    } else {
      filterData = data as Map<String, dynamic>?;
    }

    if (filterData == null) {
      throw Exception('Unexpected response format');
    }

    // 转换为前端使用的格式
    return _convertFilterToFrontendFormat(filterData);
  }

  /// 将后端 Filter 格式转换为前端格式
  static Map<String, dynamic> _convertFilterToFrontendFormat(
    Map<String, dynamic> backendFilter,
  ) {
    // 支持向后兼容：同时支持 snake_case 和驼峰命名
    final dietPrefs =
        backendFilter['dietPreferences'] ??
        backendFilter['diet_preferences'] as Map<String, dynamic>? ??
        {};
    final calorieTarget =
        backendFilter['calorieTarget'] ??
        backendFilter['calorie_target'] as Map<String, dynamic>?;
    final genSettings =
        backendFilter['generationSettings'] ??
        backendFilter['generation_settings'] as Map<String, dynamic>? ??
        {};

    return {
      'servings': backendFilter['servings'] ?? 1,
      'dish_count': genSettings['dishCount'] ?? genSettings['dish_count'] ?? 1,
      'calorie_target':
          calorieTarget?['minTotalKcal'] ??
          calorieTarget?['min_total_kcal'] ??
          calorieTarget?['maxTotalKcal'] ??
          calorieTarget?['max_total_kcal'],
      'max_cooking_time_min':
          genSettings['maxCookingTimeMin'] ??
          genSettings['max_cooking_time_min'],
      'difficulty_target':
          genSettings['difficultyTarget'] ?? genSettings['difficulty_target'],
      'diet_preferences': {
        'allergies': dietPrefs['allergies'] ?? [],
        'avoid_ingredients':
            dietPrefs['avoidIngredients'] ??
            dietPrefs['avoid_ingredients'] ??
            [],
        'diet_habits':
            dietPrefs['dietHabits'] ?? dietPrefs['diet_habits'] ?? [],
        'cuisine_preferences':
            dietPrefs['cuisinePreferences'] ??
            dietPrefs['cuisine_preferences'] ??
            [],
        'taste_preferences':
            dietPrefs['tastePreferences'] ??
            dietPrefs['taste_preferences'] ??
            [],
      },
      'cookers': backendFilter['cookers'] ?? [],
      'seasonings': backendFilter['seasonings'] ?? [],
    };
  }

  /// 获取请求headers（包含认证信息）
  static Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<List<RecipeMenuModel>> generateMenus(
    Map<String, dynamic>? filter, {
    int? householdId,
  }) async {
    // 获取householdId（优先使用传入的，否则从本地获取）
    final hId = householdId ?? await HouseholdService.getHouseholdId();
    if (hId == null) {
      throw Exception('householdId is required');
    }

    // 将householdId作为query参数传递
    final url = Uri.parse(
      '${ApiConfig.recipeBaseUrl}/api/ai/generate-menus?householdId=$hId',
    );

    final body = _buildRequestBody(filter);
    final payload = jsonEncode(body);

    // Debug prints to inspect outgoing request
    print('[RecipeApi] POST $url');
    print('[RecipeApi] body: $payload');

    final response = await http.post(
      url,
      headers: await _getHeaders(),
      body: payload,
    );

    print(
      '[RecipeApi] resp ${response.statusCode}: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}',
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to generate recipes: ${response.statusCode} ${response.body}',
      );
    }

    final data = jsonDecode(response.body);
    List<dynamic>? menusJson;

    // 处理Result<T>格式: {code: 200, msg: "...", data: [...]}
    if (data is Map && data.containsKey('code')) {
      final code = data['code'] as int;
      if (code != 200) {
        throw Exception(
          data['message']?.toString() ?? 'Failed to generate menus',
        );
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

    // 🔍 DEBUG: 查看每个menu的原始数据，特别是category字段
    for (var i = 0; i < menusJson.length; i++) {
      final menuData = menusJson[i];
      print('🔍 [RecipeApi] Menu ${i + 1}:');
      if (menuData is Map && menuData['recipes'] is List) {
        final recipes = menuData['recipes'] as List;
        for (var j = 0; j < recipes.length; j++) {
          final recipe = recipes[j];
          if (recipe is Map) {
            print('  Recipe ${j + 1}: title="${recipe['title']}", category="${recipe['category']}"');
          }
        }
      }
    }

    return menusJson
        .map<RecipeMenuModel>((e) => RecipeMenuModel.fromJson(e))
        .toList();
  }

  /// 流式生成菜单 (SSE)：每收到一个菜单即 yield，供 UI 逐条展示。
  static Stream<RecipeMenuModel> generateMenusStream(
    Map<String, dynamic>? filter, {
    int? householdId,
  }) async* {
    final hId = householdId ?? await HouseholdService.getHouseholdId();
    if (hId == null) {
      throw Exception('householdId is required');
    }
    final uri = Uri.parse(
      '${ApiConfig.recipeBaseUrl}/api/ai/generate-menus/stream?householdId=$hId',
    );
    final body = _buildRequestBody(filter);
    final request = http.Request('POST', uri);
    request.headers['Content-Type'] = 'application/json';
    request.headers['Accept'] = 'text/event-stream';
    final token = await AuthService.getToken();
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.body = jsonEncode(body);
    debugPrint('[RecipeApi] POST SSE $uri');
    final client = http.Client();
    try {
      final streamed = await client.send(request);
      if (streamed.statusCode != 200) {
        final bytes = await streamed.stream.toList();
        final msg = utf8.decode(bytes.expand((x) => x).toList());
        throw Exception('SSE failed ${streamed.statusCode}: $msg');
      }
      await for (final line in streamed.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())) {
        if (!line.startsWith('data:')) continue;
        final jsonStr = line.substring(5).trim();
        if (jsonStr.isEmpty) continue;
        try {
          final data = jsonDecode(jsonStr) as Map<String, dynamic>;
          debugPrint('[SSE] Received menu: ${data['menuId']}');
          yield RecipeMenuModel.fromJson(data);
        } catch (e) {
          debugPrint('[RecipeApi] SSE parse error: $e');
        }
      }
    } finally {
      client.close();
    }
  }

  static Map<String, dynamic> _buildRequestBody(Map<String, dynamic>? filter) {
    final f = filter ?? {};
    // 支持向后兼容：同时支持 snake_case 和驼峰命名
    final diet = f['dietPreferences'] ?? f['diet_preferences'] ?? {};
    final allergies = (diet['allergies'] as List?) ?? [];
    final avoid =
        (diet['avoidIngredients'] ?? diet['avoid_ingredients'] as List?) ?? [];
    final dietHabits =
        (diet['dietHabits'] ?? diet['diet_habits'] as List?) ?? [];
    final cuisines =
        (diet['cuisinePreferences'] ?? diet['cuisine_preferences'] as List?) ??
        [];
    final tastes =
        (diet['tastePreferences'] ?? diet['taste_preferences'] as List?) ?? [];

    final calorie = f['calorieTarget'] ?? f['calorie_target'];
    Map<String, dynamic>? calorieTarget;
    if (calorie != null) {
      final numValue = calorie is num
          ? calorie.toDouble()
          : double.tryParse(calorie.toString());
      if (numValue != null) {
        calorieTarget = {'minTotalKcal': numValue, 'maxTotalKcal': numValue};
      }
    }

    final genSettings =
        f['generationSettings'] ?? f['generation_settings'] ?? {};
    // 兼容前端当前存储格式：dish_count / max_cooking_time_min / difficulty_target 在顶层
    // 也兼容后端/未来格式：都放在 generationSettings 里（驼峰或 snake_case）
    int _coerceInt(dynamic v, int fallback) {
      if (v == null) return fallback;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? fallback;
    }

    String? _coerceDifficulty(dynamic v) {
      if (v == null) return null;
      // Filter 页面会传 List<String>（多选）；后端是 String difficultyTarget
      if (v is List) {
        if (v.isEmpty) return null;
        return v.first?.toString();
      }
      return v.toString();
    }

    final resolvedDishCount = _coerceInt(
      genSettings['dish_count'] ??
          genSettings['dishCount'] ??
          f['dish_count'] ??
          f['dishCount'],
      1,
    );
    final resolvedMaxCookingTimeMin =
        genSettings['max_cooking_time_min'] ??
        genSettings['maxCookingTimeMin'] ??
        f['max_cooking_time_min'] ??
        f['maxCookingTimeMin'];
    final resolvedDifficultyTarget = _coerceDifficulty(
      genSettings['difficulty_target'] ??
          genSettings['difficultyTarget'] ??
          f['difficulty_target'] ??
          f['difficultyTarget'],
    );
    return {
      'inventory': f['inventory'] ?? [],
      'servings': f['servings'] ?? 1,
      'dietPreferences': {
        'allergies': allergies,
        'avoidIngredients': avoid,
        'dietHabits': dietHabits,
        'cuisinePreferences': cuisines,
        'tastePreferences': tastes,
      },
      'generationSettings': {
        'dishCount': resolvedDishCount,
        'maxCookingTimeMin': resolvedMaxCookingTimeMin,
        'difficultyTarget':
            resolvedDifficultyTarget, // now can be list for multi-select
      },
      'calorieTarget': calorieTarget,
      // ✅ cookers 和 seasonings 由后端从数据库自动获取，前端发送空数组
      'cookers': [],
      'seasonings': [],
    };
  }
}
