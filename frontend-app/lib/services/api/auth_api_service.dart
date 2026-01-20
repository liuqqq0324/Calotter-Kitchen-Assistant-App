// 认证相关的纯API调用服务
// 只负责HTTP请求，不包含业务逻辑（如存储token等）
// 业务逻辑应在 services/business/auth_service.dart 中实现

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:personal_sous_chef/core/config/api_config.dart';
import 'package:personal_sous_chef/core/constants/api_endpoints.dart';

class AuthApiService {
  /// 注册用户
  /// POST /api/user/register
  static Future<http.Response> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiEndpoints.userRegister}');
    
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );
  }

  /// 用户登录
  /// POST /api/user/login
  static Future<http.Response> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiEndpoints.userLogin}');
    
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'usernameOrEmail': usernameOrEmail,
        'password': password,
      }),
    );
  }

  /// 用户登出
  /// POST /api/user/logout
  static Future<http.Response> logout({
    required String token,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiEndpoints.userLogout}');
    
    return await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }
}

