// lib/services/homepage_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:personal_sous_chef/config/api_config.dart';
import 'package:personal_sous_chef/services/auth_service.dart';

/// Homepage API Service
/// 处理营养和摄入相关的API调用
class HomepageApiService {
  /// 获取基础headers（仅Content-Type，不包含Authorization）
  /// 注意：此模块使用 userId 作为 URL 参数，与其他模块（inventory）保持一致
  static Map<String, String> _getHeaders() {
    return {'Content-Type': 'application/json'};
  }

  /// 处理R<T>响应格式
  /// 后端返回格式: {code: 200, msg: "操作成功", data: {...}}
  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body);

      // 检查是否是R<T>格式
      if (data is Map && data.containsKey('code')) {
        final code = data['code'] as int;
        final msg = data['msg'] as String? ?? '';
        final responseData = data['data'];

        if (code == 200) {
          return {
            'success': true,
            'data': responseData,
            'code': code,
            'msg': msg,
          };
        } else {
          // 根据不同的错误码返回不同的错误信息
          String errorMsg = msg;
          if (code == 401 || code == 403) {
            errorMsg = 'Unauthorized: Please login again';
          } else if (code == 404) {
            errorMsg = 'Resource not found';
          } else if (code == 500) {
            errorMsg = 'Server error: $msg';
          }

          return {
            'success': false,
            'error': errorMsg,
            'code': code,
            'msg': msg,
          };
        }
      }

      // 如果不是R<T>格式，直接返回数据（兼容旧格式）
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'error': data['message'] ?? 'Request failed',
          'code': response.statusCode,
        };
      }
    } catch (e) {
      // JSON解析失败
      return {
        'success': false,
        'error': 'Invalid response format: $e',
        'code': response.statusCode,
      };
    }
  }

  /// 1. 获取周营养目标
  /// GET /api/nutrition/targets/weekly?userId={userId}
  static Future<Map<String, dynamic>> getWeeklyNutritionTargets({
    String? userId,
  }) async {
    try {
      final userIdParam = userId ?? await AuthService.getUserId();
      if (userIdParam == null) {
        return {'success': false, 'error': 'User not logged in', 'code': 401};
      }

      final url = Uri.parse(
        '${ApiConfig.homepageBaseUrl}/api/nutrition/targets/weekly?userId=$userIdParam',
      );
      final headers = _getHeaders();

      print('[HomepageApi] GET $url');

      final response = await http
          .get(url, headers: headers)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception(
                'Request timeout: Server did not respond in time',
              );
            },
          );

      print(
        '[HomepageApi] Response ${response.statusCode}: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}',
      );

      return _handleResponse(response);
    } on http.ClientException catch (e) {
      // 网络连接错误
      return {
        'success': false,
        'error':
            'Network connection failed. Please check your internet connection.',
        'code': 0,
      };
    } on Exception catch (e) {
      // 超时或其他异常
      String errorMsg = 'Network error';
      if (e.toString().contains('timeout')) {
        errorMsg = 'Request timeout. Please try again.';
      } else if (e.toString().contains('Failed host lookup') ||
          e.toString().contains('Connection refused')) {
        errorMsg =
            'Cannot connect to server. Please check:\n'
            '1. Backend service is running on port ${ApiConfig.homepagePort}\n'
            '2. IP address is correct (${ApiConfig.serverIp})\n'
            '3. Network connection is available';
      } else {
        errorMsg = 'Network error: ${e.toString()}';
      }
      return {'success': false, 'error': errorMsg, 'code': 0};
    } catch (e) {
      return {
        'success': false,
        'error': 'Unexpected error: ${e.toString()}',
        'code': 0,
      };
    }
  }

  /// 2. 获取周营养摘要
  /// GET /api/nutrition/summary?period=week&userId={userId}
  static Future<Map<String, dynamic>> getWeeklyNutritionSummary({
    String? userId,
  }) async {
    try {
      final userIdParam = userId ?? await AuthService.getUserId();
      if (userIdParam == null) {
        return {'success': false, 'error': 'User not logged in', 'code': 401};
      }

      final url = Uri.parse(
        '${ApiConfig.homepageBaseUrl}/api/nutrition/summary?period=week&userId=$userIdParam',
      );
      final headers = _getHeaders();

      print('[HomepageApi] GET $url');

      final response = await http
          .get(url, headers: headers)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception(
                'Request timeout: Server did not respond in time',
              );
            },
          );

      print(
        '[HomepageApi] Response ${response.statusCode}: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}',
      );

      return _handleResponse(response);
    } on http.ClientException catch (e) {
      return {
        'success': false,
        'error':
            'Network connection failed. Please check your internet connection.',
        'code': 0,
      };
    } on Exception catch (e) {
      String errorMsg = 'Network error';
      if (e.toString().contains('timeout')) {
        errorMsg = 'Request timeout. Please try again.';
      } else if (e.toString().contains('Failed host lookup') ||
          e.toString().contains('Connection refused')) {
        errorMsg =
            'Cannot connect to server. Please check:\n'
            '1. Backend service is running on port ${ApiConfig.homepagePort}\n'
            '2. IP address is correct (${ApiConfig.serverIp})\n'
            '3. Network connection is available';
      } else {
        errorMsg = 'Network error: ${e.toString()}';
      }
      return {'success': false, 'error': errorMsg, 'code': 0};
    } catch (e) {
      return {
        'success': false,
        'error': 'Unexpected error: ${e.toString()}',
        'code': 0,
      };
    }
  }

  /// 3. 获取今日摄入记录
  /// GET /api/intake/today?source=recipe|manual|all&userId={userId}
  static Future<Map<String, dynamic>> getTodayIntakes({
    String source = 'all',
    String? userId,
  }) async {
    try {
      final userIdParam = userId ?? await AuthService.getUserId();
      if (userIdParam == null) {
        return {'success': false, 'error': 'User not logged in', 'code': 401};
      }

      final url = Uri.parse(
        '${ApiConfig.homepageBaseUrl}/api/intake/today?source=$source&userId=$userIdParam',
      );
      final headers = _getHeaders();

      print('[HomepageApi] GET $url');

      final response = await http
          .get(url, headers: headers)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception(
                'Request timeout: Server did not respond in time',
              );
            },
          );

      print(
        '[HomepageApi] Response ${response.statusCode}: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}',
      );

      return _handleResponse(response);
    } on http.ClientException catch (e) {
      return {
        'success': false,
        'error':
            'Network connection failed. Please check your internet connection.',
        'code': 0,
      };
    } on Exception catch (e) {
      String errorMsg = 'Network error';
      if (e.toString().contains('timeout')) {
        errorMsg = 'Request timeout. Please try again.';
      } else if (e.toString().contains('Failed host lookup') ||
          e.toString().contains('Connection refused')) {
        errorMsg =
            'Cannot connect to server. Please check:\n'
            '1. Backend service is running on port ${ApiConfig.homepagePort}\n'
            '2. IP address is correct (${ApiConfig.serverIp})\n'
            '3. Network connection is available';
      } else {
        errorMsg = 'Network error: ${e.toString()}';
      }
      return {'success': false, 'error': errorMsg, 'code': 0};
    } catch (e) {
      return {
        'success': false,
        'error': 'Unexpected error: ${e.toString()}',
        'code': 0,
      };
    }
  }

  /// 4. 更新摄入百分比
  /// PATCH /api/intake/{intake_id}?userId={userId}
  static Future<Map<String, dynamic>> updateIntakePercentage({
    required int intakeId,
    required double consumedPercentage,
    String? userId,
  }) async {
    try {
      final userIdParam = userId ?? await AuthService.getUserId();
      if (userIdParam == null) {
        return {'success': false, 'error': 'User not logged in', 'code': 401};
      }

      final url = Uri.parse(
        '${ApiConfig.homepageBaseUrl}/api/intake/$intakeId?userId=$userIdParam',
      );
      final headers = _getHeaders();

      final body = jsonEncode({'consumedPercentage': consumedPercentage});

      print('[HomepageApi] PATCH $url');
      print('[HomepageApi] Body: $body');

      final response = await http
          .patch(url, headers: headers, body: body)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception(
                'Request timeout: Server did not respond in time',
              );
            },
          );

      print(
        '[HomepageApi] Response ${response.statusCode}: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}',
      );

      return _handleResponse(response);
    } on http.ClientException catch (e) {
      return {
        'success': false,
        'error':
            'Network connection failed. Please check your internet connection.',
        'code': 0,
      };
    } on Exception catch (e) {
      String errorMsg = 'Network error';
      if (e.toString().contains('timeout')) {
        errorMsg = 'Request timeout. Please try again.';
      } else if (e.toString().contains('Failed host lookup') ||
          e.toString().contains('Connection refused')) {
        errorMsg =
            'Cannot connect to server. Please check:\n'
            '1. Backend service is running on port ${ApiConfig.homepagePort}\n'
            '2. IP address is correct (${ApiConfig.serverIp})\n'
            '3. Network connection is available';
      } else {
        errorMsg = 'Network error: ${e.toString()}';
      }
      return {'success': false, 'error': errorMsg, 'code': 0};
    } catch (e) {
      return {
        'success': false,
        'error': 'Unexpected error: ${e.toString()}',
        'code': 0,
      };
    }
  }

  /// 5. 添加手动摄入
  /// POST /api/intake/manual?userId={userId}
  static Future<Map<String, dynamic>> addManualIntake({
    required String foodName,
    String? portionDescription,
    DateTime? date,
    String? userId,
  }) async {
    try {
      final userIdParam = userId ?? await AuthService.getUserId();
      if (userIdParam == null) {
        return {'success': false, 'error': 'User not logged in', 'code': 401};
      }

      final url = Uri.parse(
        '${ApiConfig.homepageBaseUrl}/api/intake/manual?userId=$userIdParam',
      );
      final headers = _getHeaders();

      final targetDate = date ?? DateTime.now();
      final dateStr =
          '${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}';

      final body = jsonEncode({
        'date': dateStr,
        'foodName': foodName,
        if (portionDescription != null)
          'portionDescription': portionDescription,
      });

      print('[HomepageApi] POST $url');
      print('[HomepageApi] Body: $body');

      final response = await http
          .post(url, headers: headers, body: body)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception(
                'Request timeout: Server did not respond in time',
              );
            },
          );

      print(
        '[HomepageApi] Response ${response.statusCode}: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}',
      );

      return _handleResponse(response);
    } on http.ClientException catch (e) {
      return {
        'success': false,
        'error':
            'Network connection failed. Please check your internet connection.',
        'code': 0,
      };
    } on Exception catch (e) {
      String errorMsg = 'Network error';
      if (e.toString().contains('timeout')) {
        errorMsg = 'Request timeout. Please try again.';
      } else if (e.toString().contains('Failed host lookup') ||
          e.toString().contains('Connection refused')) {
        errorMsg =
            'Cannot connect to server. Please check:\n'
            '1. Backend service is running on port ${ApiConfig.homepagePort}\n'
            '2. IP address is correct (${ApiConfig.serverIp})\n'
            '3. Network connection is available';
      } else {
        errorMsg = 'Network error: ${e.toString()}';
      }
      return {'success': false, 'error': errorMsg, 'code': 0};
    } catch (e) {
      return {
        'success': false,
        'error': 'Unexpected error: ${e.toString()}',
        'code': 0,
      };
    }
  }
}
