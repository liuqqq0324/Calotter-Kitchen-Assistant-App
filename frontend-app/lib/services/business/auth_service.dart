import 'dart:convert';
// ⚠️ 已拆分：纯API调用已移至 services/api/auth_api_service.dart
// import 'package:http/http.dart' as http;
import 'package:personal_sous_chef/core/constants/storage_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:personal_sous_chef/services/business/standard_library_service.dart';
import 'package:personal_sous_chef/services/api/auth_api_service.dart';

class AuthService {
  // ⚠️ 已拆分：存储键常量已移至 core/constants/storage_keys.dart
  // 请使用 StorageKeys 类访问这些常量
  // static const String _tokenKey = 'auth_token';
  // static const String _userIdKey = 'user_id';
  // static const String _householdIdKey = 'household_id';

  // 使用新的存储键常量
  static const String _tokenKey = StorageKeys.authToken;
  static const String _userIdKey = StorageKeys.userId;
  static const String _householdIdKey = StorageKeys.householdId;

  // Register
  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      // ⚠️ 已拆分：纯API调用已移至 services/api/auth_api_service.dart
      // 请使用 AuthApiService.register() 进行HTTP请求
      // API路径: /api/user/register (统一使用 /api/user 路径)
      // final url = Uri.parse('${ApiConfig.baseUrl}/api/user/register');
      //  前端验证密码匹配，但不发送 confirmPassword 给后端
      if (password != confirmPassword) {
        return {'success': false, 'error': 'Passwords do not match'};
      }
      // final response = await http.post(
      //   url,
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode({
      //     'username': username,
      //     'email': email,
      //     'password': password,
      //     // 'confirmPassword': confirmPassword,
      //     //  不发送 confirmPassword，后端不需要
      //   }),
      // );

      // 使用新的API服务层
      final response = await AuthApiService.register(
        username: username,
        email: email,
        password: password,
      );

      final data = jsonDecode(response.body);
      // 适配后端返回的 Result<T> 格式
      if (response.statusCode == 200 && data['code'] == 200) {
        // 后端返回格式: {code: 200, message: "...", data: {...}}
        final responseData = data['data'];

        // 保存 token、userId 和 householdId（注册成功后自动登录）
        if (responseData['token'] != null && responseData['userId'] != null) {
          await _saveToken(responseData['token']);
          await _saveUserId(responseData['userId'].toString());
          if (responseData['householdId'] != null) {
            await _saveHouseholdId(responseData['householdId'].toString());
          }
        }

        return {'success': true, 'data': responseData};
      } else {
        // 后端返回错误格式: {code: 400/500, message: "错误信息"}
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
            '1. Backend service is running on port 8080\n'
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
      // ⚠️ 已拆分：纯API调用已移至 services/api/auth_api_service.dart
      // 请使用 AuthApiService.login() 进行HTTP请求
      // API路径: /api/user/login (统一使用 /api/user 路径)
      // final url = Uri.parse('${ApiConfig.baseUrl}/api/user/login');
      //
      // final response = await http.post(
      //   url,
      //   headers: {'Content-Type': 'application/json'},
      //   // 步骤2.2: 修改字段名 identifier → usernameOrEmail
      //   body: jsonEncode({'usernameOrEmail': identifier, 'password': password}),
      // );

      // 使用新的API服务层
      final response = await AuthApiService.login(
        usernameOrEmail: identifier,
        password: password,
      );

      final data = jsonDecode(response.body);

      //  步骤2.3: 适配后端返回的 Result<T> 格式
      if (response.statusCode == 200 && data['code'] == 200) {
        // 后端返回格式: {code: 200, message: "...", data: {...}}
        final responseData = data['data'];

        // 步骤2.4: token 是字符串，不是对象
        if (responseData['userId'] == null || responseData['userId'] == 0) {
          return {'success': false, 'error': 'Invalid username or password'};
        }

        // 直接使用 token（字符串），不是 data['token']['accessToken']
        await _saveToken(responseData['token']);
        await _saveUserId(responseData['userId'].toString());
        if (responseData['householdId'] != null) {
          await _saveHouseholdId(responseData['householdId'].toString());
        }

        // ✅ 登录成功后，后台异步预加载标准库（不阻塞登录流程）
        _preloadStandardLibraries();

        return {'success': true, 'data': responseData};
      } else {
        // 后端返回错误格式: {code: 400/401/403, message: "错误信息"}
        String errorMessage = 'Login failed';
        if (data['code'] == 401) {
          errorMessage = 'Invalid username or password';
        } else if (data['code'] == 403) {
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
      // ⚠️ 已拆分：纯API调用已移至 services/api/auth_api_service.dart
      // 请使用 AuthApiService.logout() 进行HTTP请求
      // API路径: /api/user/logout (统一使用 /api/user 路径)
      // final url = Uri.parse('${ApiConfig.baseUrl}/api/user/logout');
      final token = await getToken();

      // final response = await http.post(
      //   url,
      //   headers: {
      //     'Content-Type': 'application/json',
      //     if (token != null) 'Authorization': 'Bearer $token',
      //   },
      // );

      // 使用新的API服务层
      final response = await AuthApiService.logout(token: token ?? '');

      // ✅ 无论 API 响应如何，都清除本地存储
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userIdKey);
      await prefs.remove(_householdIdKey);

      // ✅ 适配后端返回的 Result<T> 格式
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['code'] == 200) {
        return {
          'success': true,
          'message': data['data'] ?? 'Logged out successfully',
        };
      } else {
        // 即使 API 失败，本地存储已清除，仍返回成功
        return {
          'success': true,
          'message': 'Logged out (local storage cleared)',
        };
      }
    } catch (e) {
      // ✅ 即使网络错误，也清除本地存储
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userIdKey);
      await prefs.remove(_householdIdKey);
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

  // Get stored household ID
  static Future<String?> getHouseholdId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_householdIdKey);
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

  // Save household ID
  static Future<void> _saveHouseholdId(String householdId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_householdIdKey, householdId);
  }

  // ✅ 后台异步预加载标准库（不阻塞登录流程）
  static void _preloadStandardLibraries() {
    // 不等待完成，后台静默加载
    Future.microtask(() async {
      try {
        await StandardLibraryService.preloadOnLogin();
        // ignore: avoid_print
        print('[AuthService] Standard libraries preloaded successfully');
      } catch (e) {
        // 静默失败，不影响登录流程
        // ignore: avoid_print
        print('[AuthService] Failed to preload standard libraries: $e');
      }
    });
  }
}
