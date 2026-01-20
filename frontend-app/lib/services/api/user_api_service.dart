// 用户相关的纯API调用服务
// 只负责HTTP请求，不包含业务逻辑
// 业务逻辑应在 services/business/user_service.dart 中实现

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:personal_sous_chef/core/config/api_config.dart';
import 'package:personal_sous_chef/core/constants/api_endpoints.dart';

class UserApiService {
  /// 获取授权请求头
  static Map<String, String> _getHeaders(String? token) {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// 获取用户简要信息
  /// GET /api/user?id={userId}
  static Future<http.Response> getUserInfo({
    required String userId,
    String? token,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiEndpoints.userInfo}?id=$userId');
    
    return await http.get(url, headers: _getHeaders(token));
  }

  /// 更新用户信息
  /// PUT /api/user?id={userId}
  static Future<http.Response> updateUserInfo({
    required String userId,
    required Map<String, dynamic> profile,
    String? token,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiEndpoints.userInfo}?id=$userId');
    
    return await http.put(
      url,
      headers: _getHeaders(token),
      body: jsonEncode({
        'userId': int.parse(userId),
        'profile': profile,
      }),
    );
  }

  /// 获取用户偏好设置
  /// GET /api/user/preferences?id={userId}
  static Future<http.Response> getUserPreferences({
    required String userId,
    String? token,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}${ApiEndpoints.userPreferences}?id=$userId',
    );
    
    return await http.get(url, headers: _getHeaders(token));
  }

  /// 更新用户偏好设置
  /// PUT /api/user/preferences?id={userId}
  static Future<http.Response> updateUserPreferences({
    required String userId,
    String? dietaryType,
    List<String>? cuisineTypes,
    String? spiceLevel,
    String? cookingTimePreference,
    String? token,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}${ApiEndpoints.userPreferences}?id=$userId',
    );
    
    return await http.put(
      url,
      headers: _getHeaders(token),
      body: jsonEncode({
        'dietaryType': dietaryType,
        'cuisineTypes': cuisineTypes ?? [],
        'spiceLevel': spiceLevel,
        'cookingTimePreference': cookingTimePreference,
      }),
    );
  }

  /// 获取用户饮食习惯
  /// GET /api/user/diet-habits?id={userId}
  static Future<http.Response> getUserDietHabits({
    required String userId,
    String? token,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}${ApiEndpoints.userDietHabits}?id=$userId',
    );
    
    return await http.get(url, headers: _getHeaders(token));
  }

  /// 更新用户饮食习惯
  /// PUT /api/user/diet-habits?id={userId}
  static Future<http.Response> updateUserDietHabits({
    required String userId,
    required List<String> dietHabits,
    String? token,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}${ApiEndpoints.userDietHabits}?id=$userId',
    );
    
    return await http.put(
      url,
      headers: _getHeaders(token),
      body: jsonEncode({'dietHabits': dietHabits}),
    );
  }

  /// 获取用户过敏信息
  /// GET /api/user/allergies?id={userId}
  static Future<http.Response> getUserAllergies({
    required String userId,
    String? token,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}${ApiEndpoints.userAllergies}?id=$userId',
    );
    
    return await http.get(url, headers: _getHeaders(token));
  }

  /// 更新用户过敏信息
  /// PUT /api/user/allergies?id={userId}
  static Future<http.Response> updateUserAllergies({
    required String userId,
    required List<String> allergies,
    String? token,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}${ApiEndpoints.userAllergies}?id=$userId',
    );
    
    return await http.put(
      url,
      headers: _getHeaders(token),
      body: jsonEncode({'allergies': allergies}),
    );
  }

  /// 获取用户偏好映射（TASTE, CUISINE, DISLIKE）
  /// GET /api/user/preferences-map?id={userId}
  static Future<http.Response> getUserPreferencesMap({
    required String userId,
    String? token,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}${ApiEndpoints.userPreferencesMap}?id=$userId',
    );
    
    return await http.get(url, headers: _getHeaders(token));
  }

  /// 更新用户偏好映射（TASTE, CUISINE）
  /// PUT /api/user/preferences-map?id={userId}
  static Future<http.Response> updateUserPreferencesMap({
    required String userId,
    List<String>? tastes,
    List<String>? cuisines,
    String? token,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}${ApiEndpoints.userPreferencesMap}?id=$userId',
    );
    
    return await http.put(
      url,
      headers: _getHeaders(token),
      body: jsonEncode({
        'tastes': tastes ?? [],
        'cuisines': cuisines ?? [],
      }),
    );
  }

  /// 获取用户健康信息（BMI和营养目标）
  /// GET /api/user/health-info?id={userId}
  static Future<http.Response> getUserHealthInfo({
    required String userId,
    String? token,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}${ApiEndpoints.userHealthInfo}?id=$userId',
    );
    
    return await http.get(url, headers: _getHeaders(token));
  }

  /// 创建或更新健康目标
  /// POST /api/user/health-goal?id={userId}
  static Future<http.Response> createOrUpdateHealthGoal({
    required String userId,
    required String goalType, // "MAINTENANCE", "LOSE_FAT", "MUSCLE_GAIN"
    String? token,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}${ApiEndpoints.userHealthGoal}?id=$userId',
    );
    
    return await http.post(
      url,
      headers: _getHeaders(token),
      body: jsonEncode({'goalType': goalType}),
    );
  }

  /// 获取标准过敏原列表
  /// GET /api/user/standard-allergens
  static Future<http.Response> getStandardAllergens({
    String? token,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}${ApiEndpoints.userStandardAllergens}',
    );
    
    return await http.get(url, headers: _getHeaders(token));
  }
}

