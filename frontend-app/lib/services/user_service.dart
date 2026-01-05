import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:personal_sous_chef/config/api_config.dart';
import 'package:personal_sous_chef/services/auth_service.dart';

class UserService {
  // Get authorization header
  static Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Get user brief info
  static Future<Map<String, dynamic>> getUserBriefInfo({String? userId}) async {
    try {
      final userIdParam = userId ?? await AuthService.getUserId();
      final url = Uri.parse(
        '${ApiConfig.baseUrl}/api/user?id=$userIdParam',
      );
      final response = await http.get(url, headers: await _getHeaders());

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        // 后端返回的是 Result<UserResponse> 格式: {code, message, data: {userId, userName, ...}}
        // 需要提取 data.data 字段
        final userData = data['data'] ?? data;
        return {'success': true, 'data': userData};
      } else {
        return {
          'success': false,
          'error': data['message'] ?? 'Failed to get user info',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // Update user info
  static Future<Map<String, dynamic>> updateUserInfo({
    String? userId,
    String? birthdate, // Changed from age to birthdate (ISO format: YYYY-MM-DD)
    String? gender,
    int? height,
    int? weight,
  }) async {
    try {
      final userIdParam = userId ?? await AuthService.getUserId();
      final url = Uri.parse(
        '${ApiConfig.baseUrl}/api/user?id=$userIdParam',
      );
      
      // Build profile map, only include non-null values
      final Map<String, dynamic> profile = {};
      if (birthdate != null && birthdate.isNotEmpty) {
        profile['birthdate'] = birthdate;
      }
      if (gender != null && gender.isNotEmpty) {
        profile['gender'] = gender;
      }
      if (height != null) {
        profile['height'] = height;
      }
      if (weight != null) {
        profile['weight'] = weight;
      }
      
      final response = await http.put(
        url,
        headers: await _getHeaders(),
        body: jsonEncode({
          'userId': int.parse(userIdParam ?? '0'),
          'profile': profile,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        // 后端返回的是 Result<UserResponse> 格式: {code, message, data: {userId, userName, ...}}
        // 需要提取 data.data 字段
        final userData = data['data'] ?? data;
        return {'success': true, 'data': userData};
      } else {
        return {
          'success': false,
          'error': data['message'] ?? 'Failed to update user info',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // Get user preferences
  static Future<Map<String, dynamic>> getUserPreferences({
    String? userId,
  }) async {
    try {
      final userIdParam = userId ?? await AuthService.getUserId();
      final url = Uri.parse(
        '${ApiConfig.baseUrl}/api/user/preferences?id=$userIdParam',
      );
      final response = await http.get(url, headers: await _getHeaders());

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        // 后端返回的是 Result<PreferencesResponse> 格式: {code, message, data: {preferences: {...}}}
        // 需要提取 data.data 字段
        final responseData = data['data'] ?? data;
        return {'success': true, 'data': responseData};
      } else {
        return {
          'success': false,
          'error': data['message'] ?? 'Failed to get preferences',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // Update user preferences
  static Future<Map<String, dynamic>> updateUserPreferences({
    String? userId,
    String? dietaryType,
    List<String>? cuisineTypes,
    String? spiceLevel,
    String? cookingTimePreference,
  }) async {
    try {
      final userIdParam = userId ?? await AuthService.getUserId();
      final url = Uri.parse(
        '${ApiConfig.baseUrl}/api/user/preferences?id=$userIdParam',
      );
      final response = await http.put(
        url,
        headers: await _getHeaders(),
        body: jsonEncode({
          'dietaryType': dietaryType,
          'cuisineTypes': cuisineTypes ?? [],
          'spiceLevel': spiceLevel,
          'cookingTimePreference': cookingTimePreference,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        // 后端返回的是 Result<PreferencesResponse> 格式: {code, message, data: {preferences: {...}}}
        // 需要提取 data.data 字段
        final responseData = data['data'] ?? data;
        return {'success': true, 'data': responseData};
      } else {
        return {
          'success': false,
          'error': data['message'] ?? 'Failed to update preferences',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // Get user taboos
  static Future<Map<String, dynamic>> getUserTaboos({String? userId}) async {
    try {
      final userIdParam = userId ?? await AuthService.getUserId();
      final url = Uri.parse(
        '${ApiConfig.baseUrl}/api/user/taboos?id=$userIdParam',
      );
      final response = await http.get(url, headers: await _getHeaders());

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        // 后端返回的是 Result<TaboosResponse> 格式: {code, message, data: {taboos: [...]}}
        // 需要提取 data.data 字段
        final responseData = data['data'] ?? data;
        return {'success': true, 'data': responseData};
      } else {
        return {
          'success': false,
          'error': data['message'] ?? 'Failed to get taboos',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // Update user taboos
  static Future<Map<String, dynamic>> updateUserTaboos({
    String? userId,
    required List<String> taboos,
  }) async {
    try {
      final userIdParam = userId ?? await AuthService.getUserId();
      final url = Uri.parse(
        '${ApiConfig.baseUrl}/api/user/taboos?id=$userIdParam',
      );
      final response = await http.put(
        url,
        headers: await _getHeaders(),
        body: jsonEncode({'taboos': taboos}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        // 后端返回的是 Result<TaboosResponse> 格式: {code, message, data: {taboos: [...]}}
        // 需要提取 data.data 字段
        final responseData = data['data'] ?? data;
        return {'success': true, 'data': responseData};
      } else {
        return {
          'success': false,
          'error': data['message'] ?? 'Failed to update taboos',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // Get user allergies
  static Future<Map<String, dynamic>> getUserAllergies({String? userId}) async {
    try {
      final userIdParam = userId ?? await AuthService.getUserId();
      final url = Uri.parse(
        '${ApiConfig.baseUrl}/api/user/allergies?id=$userIdParam',
      );
      final response = await http.get(url, headers: await _getHeaders());

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        // 后端返回的是 Result<AllergiesResponse> 格式: {code, message, data: {allergies: [...]}}
        // 需要提取 data.data 字段
        final responseData = data['data'] ?? data;
        return {'success': true, 'data': responseData};
      } else {
        return {
          'success': false,
          'error': data['message'] ?? 'Failed to get allergies',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // Update user allergies
  static Future<Map<String, dynamic>> updateUserAllergies({
    String? userId,
    required List<String> allergies,
  }) async {
    try {
      final userIdParam = userId ?? await AuthService.getUserId();
      final url = Uri.parse(
        '${ApiConfig.baseUrl}/api/user/allergies?id=$userIdParam',
      );
      final response = await http.put(
        url,
        headers: await _getHeaders(),
        body: jsonEncode({'allergies': allergies}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        // 后端返回的是 Result<AllergiesResponse> 格式: {code, message, data: {allergies: [...]}}
        // 需要提取 data.data 字段
        final responseData = data['data'] ?? data;
        return {'success': true, 'data': responseData};
      } else {
        return {
          'success': false,
          'error': data['message'] ?? 'Failed to update allergies',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // Get user preferences map (TASTE, CUISINE, DISLIKE)
  static Future<Map<String, dynamic>> getUserPreferencesMap({
    String? userId,
  }) async {
    try {
      final userIdParam = userId ?? await AuthService.getUserId();
      final url = Uri.parse(
        '${ApiConfig.baseUrl}/api/user/preferences-map?id=$userIdParam',
      );
      final response = await http.get(url, headers: await _getHeaders());

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        // 后端返回的是 Result<UserPreferencesResponse> 格式: {code, message, data: {tastes: [], cuisines: [], dislikes: []}}
        final responseData = data['data'] ?? data;
        return {'success': true, 'data': responseData};
      } else {
        return {
          'success': false,
          'error': data['message'] ?? 'Failed to get preferences',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // Update user preferences map (TASTE, CUISINE)
  static Future<Map<String, dynamic>> updateUserPreferencesMap({
    String? userId,
    List<String>? tastes,
    List<String>? cuisines,
  }) async {
    try {
      final userIdParam = userId ?? await AuthService.getUserId();
      final url = Uri.parse(
        '${ApiConfig.baseUrl}/api/user/preferences-map?id=$userIdParam',
      );
      final response = await http.put(
        url,
        headers: await _getHeaders(),
        body: jsonEncode({
          'tastes': tastes ?? [],
          'cuisines': cuisines ?? [],
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final responseData = data['data'] ?? data;
        return {'success': true, 'data': responseData};
      } else {
        return {
          'success': false,
          'error': data['message'] ?? 'Failed to update preferences',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }
}
