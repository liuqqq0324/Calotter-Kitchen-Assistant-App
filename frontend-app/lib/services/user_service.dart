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

  // Get user diet habits
  static Future<Map<String, dynamic>> getUserDietHabits({String? userId}) async {
    try {
      final userIdParam = userId ?? await AuthService.getUserId();
      final url = Uri.parse(
        '${ApiConfig.baseUrl}/api/user/diet-habits?id=$userIdParam',
      );
      final response = await http.get(url, headers: await _getHeaders());

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        // 后端返回的是 Result<DietHabitsResponse> 格式: {code, message, data: {dietHabits: [...]}}
        // 需要提取 data.data 字段
        final responseData = data['data'] ?? data;
        return {'success': true, 'data': responseData};
      } else {
        return {
          'success': false,
          'error': data['message'] ?? 'Failed to get diet habits',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // Update user diet habits
  static Future<Map<String, dynamic>> updateUserDietHabits({
    String? userId,
    required List<String> dietHabits,
  }) async {
    try {
      final userIdParam = userId ?? await AuthService.getUserId();
      final url = Uri.parse(
        '${ApiConfig.baseUrl}/api/user/diet-habits?id=$userIdParam',
      );
      final response = await http.put(
        url,
        headers: await _getHeaders(),
        body: jsonEncode({'dietHabits': dietHabits}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        // 后端返回的是 Result<DietHabitsResponse> 格式: {code, message, data: {dietHabits: [...]}}
        // 需要提取 data.data 字段
        final responseData = data['data'] ?? data;
        return {'success': true, 'data': responseData};
      } else {
        return {
          'success': false,
          'error': data['message'] ?? 'Failed to update diet habits',
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

  // Get user health info (BMI and nutrition goals)
  static Future<Map<String, dynamic>> getUserHealthInfo({
    String? userId,
  }) async {
    try {
      final userIdParam = userId ?? await AuthService.getUserId();
      final url = Uri.parse(
        '${ApiConfig.baseUrl}/api/user/health-info?id=$userIdParam',
      );
      final response = await http.get(url, headers: await _getHeaders());

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        // 后端返回的是 Result<UserHealthInfoResponse> 格式: {code, message, data: {bmi, goalType, ...}}
        final responseData = data['data'] ?? data;
        return {'success': true, 'data': responseData};
      } else {
        return {
          'success': false,
          'error': data['message'] ?? 'Failed to get health info',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // Create or update health goal
  static Future<Map<String, dynamic>> createOrUpdateHealthGoal({
    String? userId,
    required String goalType, // "MAINTENANCE", "LOSE_FAT", "MUSCLE_GAIN"
  }) async {
    try {
      final userIdParam = userId ?? await AuthService.getUserId();
      final url = Uri.parse(
        '${ApiConfig.baseUrl}/api/user/health-goal?id=$userIdParam',
      );
      
      print('📤 Creating/updating health goal:');
      print('   URL: $url');
      print('   Goal Type: $goalType');
      
      final headers = await _getHeaders();
      final body = jsonEncode({
        'goalType': goalType,
      });
      
      print('   Headers: $headers');
      print('   Body: $body');
      
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        // 后端返回的是 Result<HealthGoalResponse> 格式: {code, message, data: {id, goalType, ...}}
        final responseData = data['data'] ?? data;
        return {'success': true, 'data': responseData};
      } else {
        final errorMsg = data['message'] ?? 
                        data['error'] ?? 
                        'Failed to create or update health goal (Status: ${response.statusCode})';
        print('❌ Error: $errorMsg');
        return {
          'success': false,
          'error': errorMsg,
        };
      }
    } catch (e, stackTrace) {
      print('❌ Exception: $e');
      print('Stack trace: $stackTrace');
      return {'success': false, 'error': 'Network error: $e'};
    }
  }
}
