import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:personal_sous_chef/config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';

  // Register
  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/api/ums/auth/register');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'confirmPassword': confirmPassword,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'error': data['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      // 提供更详细的错误信息
      String errorMsg = 'Network error';
      if (e.toString().contains('Failed host lookup') ||
          e.toString().contains('Connection refused')) {
        errorMsg =
            'Cannot connect to server. Please check:\n'
            '1. Backend service is running on port ${ApiConfig.port}\n'
            '2. IP address is correct (10.0.2.2 for emulator)\n'
            '3. Network connection is available';
      } else if (e.toString().contains('Timeout')) {
        errorMsg = 'Connection timeout. Server may be slow or unreachable.';
      } else {
        errorMsg = 'Network error: $e';
      }
      return {'success': false, 'error': errorMsg};
    }
  }

  // Login
  static Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/api/ums/auth/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'identifier': identifier, 'password': password}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        // Check if login was successful (userId should not be 0)
        if (data['userId'] == null || data['userId'] == 0) {
          return {'success': false, 'error': 'Invalid username or password'};
        }
        // Save token and user ID
        await _saveToken(data['token']['accessToken']);
        await _saveUserId(data['userId'].toString());
        return {'success': true, 'data': data};
      } else {
        // Handle 401 (Unauthorized) or 403 (Forbidden) errors
        String errorMessage = 'Login failed';
        if (response.statusCode == 401) {
          errorMessage = 'Invalid username or password';
        } else if (response.statusCode == 403) {
          errorMessage = 'Account is disabled';
        }
        return {'success': false, 'error': data['message'] ?? errorMessage};
      }
    } catch (e) {
      // 提供更详细的错误信息
      String errorMsg = 'Network error';
      if (e.toString().contains('Failed host lookup') ||
          e.toString().contains('Connection refused')) {
        errorMsg =
            'Cannot connect to server. Please check:\n'
            '1. Backend service is running\n'
            '2. IP address is correct\n'
            '3. Network connection is available';
      } else if (e.toString().contains('Timeout')) {
        errorMsg = 'Connection timeout. Server may be slow or unreachable.';
      } else {
        errorMsg = 'Network error: $e';
      }
      return {'success': false, 'error': errorMsg};
    }
  }

  // Logout
  static Future<Map<String, dynamic>> logout() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/api/ums/auth/logout');
      final token = await getToken();
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      // Clear local storage regardless of API response
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userIdKey);

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Logged out successfully'};
      } else {
        // Even if API fails, we've cleared local storage
        return {
          'success': true,
          'message': 'Logged out (local storage cleared)',
        };
      }
    } catch (e) {
      // Clear local storage even if network error
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userIdKey);
      return {'success': true, 'message': 'Logged out (local storage cleared)'};
    }
  }

  // Get stored token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Get stored user ID
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Save token
  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Save user ID
  static Future<void> _saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
  }
}
