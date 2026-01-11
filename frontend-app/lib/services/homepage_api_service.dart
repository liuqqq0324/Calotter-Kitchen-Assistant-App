// lib/services/homepage_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:personal_sous_chef/config/api_config.dart';
import 'package:personal_sous_chef/services/auth_service.dart';

/// Homepage API Service
/// 处理营养和摄入相关的API调用
class HomepageApiService {
  /// 启用前端假数据（不依赖后端），用于 UI 验证：
  /// flutter run --dart-define=MOCK_HOMEPAGE_API=true
  static const bool _useMockApi =
      bool.fromEnvironment('MOCK_HOMEPAGE_API', defaultValue: false);

  // ===== Mock in-memory store (仅用于开发验证) =====
  static int _mockNextIntakeId = 900000;

  static final List<Map<String, dynamic>> _mockLeftoverOptions = [
    {
      'type': 'leftover',
      'id': 101,
      'title': 'Braised Pork (Leftover)',
      'subtitle': '250g leftover',
    },
    {
      'type': 'leftover',
      'id': 102,
      'title': 'Tomato Egg Stir-fry (Leftover)',
      'subtitle': '180g leftover',
    },
    {
      'type': 'leftover',
      'id': 103,
      'title': 'Chicken Soup (Leftover)',
      'subtitle': '300g leftover',
    },
  ];

  static final List<Map<String, dynamic>> _mockTodayDishIntakes = [
    {
      'intakeId': 1001,
      'leftoverTitle': 'Braised Pork (Leftover)',
      'consumedPercentage': 60.0, // 0-100
    },
    {
      'intakeId': 1002,
      'leftoverTitle': 'Tomato Egg Stir-fry (Leftover)',
      'consumedPercentage': 30.0,
    },
  ];

  static final List<Map<String, dynamic>> _mockTodayManualFoods = [
    {
      'intakeId': 2001,
      'manualFoodName': 'Banana',
      'effectiveNutrition': {
        'energy': 105,
        'protein': 1.3,
        'fat': 0.4,
        'carbohydrates': 27.0,
      },
    },
    {
      'intakeId': 2002,
      'manualFoodName': 'Greek Yogurt',
      'effectiveNutrition': {
        'energy': 120,
        'protein': 15.0,
        'fat': 3.5,
        'carbohydrates': 8.0,
      },
    },
  ];

  /// 获取基础headers（仅Content-Type，不包含Authorization）
  /// 注意：后端 controller 使用 userId 作为 URL 参数
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
        final msg = data['message'] as String? ?? '';
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
      if (_useMockApi) {
        // Basic mock: weekly targets and consumed numbers (best-effort).
        // Keep shape aligned with backend: {period, weekStart, weekEnd, consumed, remaining}
        final now = DateTime.now();
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 6));

        // Simple mock targets (weekly)
        const weeklyEnergyTarget = 14000.0;
        const weeklyProteinTarget = 700.0;
        const weeklyFatTarget = 455.0;
        const weeklyCarbsTarget = 1750.0;

        // Very rough mock consumed: sum today's manual foods only (if present), and treat as week-to-date.
        double consumedEnergy = 0;
        double consumedProtein = 0;
        double consumedFat = 0;
        double consumedCarbs = 0;
        for (final e in _mockTodayManualFoods) {
          final eff = (e['effectiveNutrition'] as Map?)?.cast<String, dynamic>();
          if (eff == null) continue;
          consumedEnergy += (eff['energy'] as num?)?.toDouble() ?? 0.0;
          consumedProtein += (eff['protein'] as num?)?.toDouble() ?? 0.0;
          consumedFat += (eff['fat'] as num?)?.toDouble() ?? 0.0;
          consumedCarbs += (eff['carbohydrates'] as num?)?.toDouble() ?? 0.0;
        }

        return {
          'success': true,
          'data': {
            'period': 'week',
            'weekStart':
                '${weekStart.year}-${weekStart.month.toString().padLeft(2, '0')}-${weekStart.day.toString().padLeft(2, '0')}',
            'weekEnd':
                '${weekEnd.year}-${weekEnd.month.toString().padLeft(2, '0')}-${weekEnd.day.toString().padLeft(2, '0')}',
            'consumed': {
              'energy': consumedEnergy,
              'protein': consumedProtein,
              'fat': consumedFat,
              'carbohydrates': consumedCarbs,
            },
            'remaining': {
              'energy': (weeklyEnergyTarget - consumedEnergy).clamp(0.0, 1e18),
              'protein': (weeklyProteinTarget - consumedProtein).clamp(0.0, 1e18),
              'fat': (weeklyFatTarget - consumedFat).clamp(0.0, 1e18),
              'carbohydrates': (weeklyCarbsTarget - consumedCarbs).clamp(0.0, 1e18),
            },
          },
          'code': 200,
        };
      }

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

  /// 2.1 获取日营养摘要（已消耗 + 剩余）
  /// GET /api/nutrition/summary/daily?userId={userId}&date=YYYY-MM-DD
  static Future<Map<String, dynamic>> getDailyNutritionSummary({
    String? userId,
    DateTime? date,
  }) async {
    try {
      if (_useMockApi) {
        final d = date ?? DateTime.now();
        // Simple mock consumed = sum today's manual foods only.
        double consumedEnergy = 0;
        double consumedProtein = 0;
        double consumedFat = 0;
        double consumedCarbs = 0;
        for (final e in _mockTodayManualFoods) {
          final eff = (e['effectiveNutrition'] as Map?)?.cast<String, dynamic>();
          if (eff == null) continue;
          consumedEnergy += (eff['energy'] as num?)?.toDouble() ?? 0.0;
          consumedProtein += (eff['protein'] as num?)?.toDouble() ?? 0.0;
          consumedFat += (eff['fat'] as num?)?.toDouble() ?? 0.0;
          consumedCarbs += (eff['carbohydrates'] as num?)?.toDouble() ?? 0.0;
        }

        // Simple mock daily targets
        const dailyEnergyTarget = 2000.0;
        const dailyProteinTarget = 100.0;
        const dailyFatTarget = 65.0;
        const dailyCarbsTarget = 250.0;

        return {
          'success': true,
          'data': {
            'period': 'day',
            'date':
                '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}',
            'consumed': {
              'energy': consumedEnergy,
              'protein': consumedProtein,
              'fat': consumedFat,
              'carbohydrates': consumedCarbs,
            },
            'remaining': {
              'energy': (dailyEnergyTarget - consumedEnergy).clamp(0.0, 1e18),
              'protein': (dailyProteinTarget - consumedProtein).clamp(0.0, 1e18),
              'fat': (dailyFatTarget - consumedFat).clamp(0.0, 1e18),
              'carbohydrates': (dailyCarbsTarget - consumedCarbs).clamp(0.0, 1e18),
            },
          },
          'code': 200,
        };
      }

      final userIdParam = userId ?? await AuthService.getUserId();
      if (userIdParam == null) {
        return {'success': false, 'error': 'User not logged in', 'code': 401};
      }

      final d = date ?? DateTime.now();
      final dateStr =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      final url = Uri.parse(
        '${ApiConfig.homepageBaseUrl}/api/nutrition/summary/daily?userId=$userIdParam&date=$dateStr',
      );
      final headers = _getHeaders();

      print('[HomepageApi] GET $url');

      final response = await http.get(url, headers: headers).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout: Server did not respond in time');
        },
      );

      print(
        '[HomepageApi] Response ${response.statusCode}: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}',
      );

      return _handleResponse(response);
    } on http.ClientException catch (_) {
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

  /// 2.2 获取日营养目标
  /// GET /api/nutrition/targets/daily?userId={userId}&date=YYYY-MM-DD
  static Future<Map<String, dynamic>> getDailyNutritionTargets({
    String? userId,
    DateTime? date,
  }) async {
    try {
      if (_useMockApi) {
        final d = date ?? DateTime.now();
        return {
          'success': true,
          'data': {
            'date':
                '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}',
            'dailyTarget': {
              'energy': 2000,
              'protein': 100.0,
              'fat': 65.0,
              'carbohydrates': 250.0,
              'fiber': 25.0,
            },
          },
          'code': 200,
        };
      }

      final userIdParam = userId ?? await AuthService.getUserId();
      if (userIdParam == null) {
        return {'success': false, 'error': 'User not logged in', 'code': 401};
      }

      final d = date ?? DateTime.now();
      final dateStr =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      final url = Uri.parse(
        '${ApiConfig.homepageBaseUrl}/api/nutrition/targets/daily?userId=$userIdParam&date=$dateStr',
      );
      final headers = _getHeaders();

      print('[HomepageApi] GET $url');

      final response = await http.get(url, headers: headers).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout: Server did not respond in time');
        },
      );

      print(
        '[HomepageApi] Response ${response.statusCode}: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}',
      );

      return _handleResponse(response);
    } on http.ClientException catch (_) {
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
      if (_useMockApi) {
        if (source == 'manual') {
          return {
            'success': true,
            'data': {'items': List<Map<String, dynamic>>.from(_mockTodayManualFoods)},
            'code': 200,
          };
        }
        if (source == 'recipe') {
          return {
            'success': true,
            'data': {'items': List<Map<String, dynamic>>.from(_mockTodayDishIntakes)},
            'code': 200,
          };
        }
        // 默认返回空，避免影响其它页面
        return {
          'success': true,
          'data': {'items': const []},
          'code': 200,
        };
      }

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
      if (_useMockApi) {
        final idx =
            _mockTodayDishIntakes.indexWhere((e) => (e['intakeId'] as int?) == intakeId);
        if (idx >= 0) {
          _mockTodayDishIntakes[idx] = {
            ..._mockTodayDishIntakes[idx],
            'consumedPercentage': consumedPercentage,
          };
        }
        return {'success': true, 'data': const {}, 'code': 200};
      }

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
      if (_useMockApi) {
        final newId = _mockNextIntakeId++;
        _mockTodayManualFoods.insert(0, {
          'intakeId': newId,
          'manualFoodName': foodName,
          'effectiveNutrition': {
            'energy': 180,
            'protein': 8.0,
            'fat': 6.0,
            'carbohydrates': 22.0,
          },
        });
        return {
          'success': true,
          'data': {
            'todayManualFoods': List<Map<String, dynamic>>.from(_mockTodayManualFoods),
          },
          'code': 200,
        };
      }

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

  /// 6. 删除摄入记录
  /// DELETE /api/intake/{intake_id}?userId={userId}
  static Future<Map<String, dynamic>> deleteIntake({
    required int intakeId,
    String? userId,
  }) async {
    try {
      if (_useMockApi) {
        _mockTodayDishIntakes.removeWhere((e) => (e['intakeId'] as int?) == intakeId);
        _mockTodayManualFoods.removeWhere((e) => (e['intakeId'] as int?) == intakeId);
        return {'success': true, 'data': const {}, 'code': 200};
      }

      final userIdParam = userId ?? await AuthService.getUserId();
      if (userIdParam == null) {
        return {'success': false, 'error': 'User not logged in', 'code': 401};
      }

      final url = Uri.parse(
        '${ApiConfig.homepageBaseUrl}/api/intake/$intakeId?userId=$userIdParam',
      );
      final headers = _getHeaders();

      print('[HomepageApi] DELETE $url');

      final response = await http
          .delete(url, headers: headers)
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

      // Prefer the unified R<T> handler, but also improve diagnostics for Spring default error JSON.
      final handled = _handleResponse(response);
      if (handled['success'] == false &&
          (handled['error'] == 'Request failed' ||
              (handled['error'] as String?)?.isEmpty == true)) {
        try {
          final data = jsonDecode(response.body);
          if (data is Map) {
            final status = data['status'] ?? response.statusCode;
            final error = data['error'];
            final message = data['message'];
            final path = data['path'];
            final best = (message is String && message.isNotEmpty)
                ? message
                : (error is String && error.isNotEmpty)
                ? error
                : 'Request failed';
            return {
              'success': false,
              'error': '$best (HTTP $status${path != null ? ', $path' : ''})',
              'code': status,
              'msg': best,
            };
          }
        } catch (_) {
          // ignore, keep handled
        }
      }
      return handled;
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

  /// 7. 获取可选菜品（包含 leftovers）
  /// GET /api/intake/dish/options?userId={userId}
  static Future<Map<String, dynamic>> getDishOptions({String? userId}) async {
    try {
      if (_useMockApi) {
        return {
          'success': true,
          'data': {'options': List<Map<String, dynamic>>.from(_mockLeftoverOptions)},
          'code': 200,
        };
      }

      final userIdParam = userId ?? await AuthService.getUserId();
      if (userIdParam == null) {
        return {'success': false, 'error': 'User not logged in', 'code': 401};
      }

      final url = Uri.parse(
        '${ApiConfig.homepageBaseUrl}/api/intake/dish/options?userId=$userIdParam',
      );
      final headers = _getHeaders();

      print('[HomepageApi] GET $url');

      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('Request timeout: Server did not respond in time');
      });

      print(
        '[HomepageApi] Response ${response.statusCode}: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}',
      );

      return _handleResponse(response);
    } on http.ClientException catch (_) {
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

  /// 8. 添加今日菜品摄入（仅 leftover）
  /// POST /api/intake/dish?userId={userId}
  static Future<Map<String, dynamic>> addDishIntake({
    int? id,
    List<int>? ids,
    double? consumedPercentage, // 0-100, optional
    String? userId,
  }) async {
    try {
      final hasSingle = id != null;
      final hasBatch = ids != null && ids.isNotEmpty;
      if (!hasSingle && !hasBatch) {
        return {
          'success': false,
          'error': 'id or ids is required',
          'code': 400,
        };
      }

      if (_useMockApi) {
        final pct = consumedPercentage ?? 100.0;

        final List<int> targetIds;
        if (hasBatch) {
          targetIds = ids;
        } else {
          targetIds = [id!];
        }
        final created = <Map<String, dynamic>>[];
        for (final oneId in targetIds.toSet()) {
          if (oneId <= 0) continue;
          final opt = _mockLeftoverOptions
              .cast<Map<String, dynamic>>()
              .firstWhere(
                (e) => (e['id'] as int?) == oneId,
                orElse: () => {
                  'type': 'leftover',
                  'id': oneId,
                  'title': 'Leftover $oneId',
                  'subtitle': 'mock',
                },
              );
          final newItem = {
            'intakeId': _mockNextIntakeId++,
            'leftoverTitle': (opt['title'] as String?) ?? 'Leftover $oneId',
            'consumedPercentage': pct,
          };
          _mockTodayDishIntakes.insert(0, newItem);
          created.add(newItem);
        }

        return {
          'success': true,
          'data': {
            'intake': created.isNotEmpty ? created.first : null,
            'addedIntakes': created,
            'todayDishIntakes': List<Map<String, dynamic>>.from(_mockTodayDishIntakes),
          },
          'code': 200,
        };
      }

      final userIdParam = userId ?? await AuthService.getUserId();
      if (userIdParam == null) {
        return {'success': false, 'error': 'User not logged in', 'code': 401};
      }

      final url = Uri.parse(
        '${ApiConfig.homepageBaseUrl}/api/intake/dish?userId=$userIdParam',
      );
      final headers = _getHeaders();

      final body = jsonEncode({
        'type': 'leftover',
        if (hasBatch) 'ids': ids,
        if (hasSingle) 'id': id,
        if (consumedPercentage != null) 'consumedPercentage': consumedPercentage,
      });

      print('[HomepageApi] POST $url');
      print('[HomepageApi] Body: $body');

      final response = await http
          .post(url, headers: headers, body: body)
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('Request timeout: Server did not respond in time');
      });

      print(
        '[HomepageApi] Response ${response.statusCode}: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}',
      );

      return _handleResponse(response);
    } on http.ClientException catch (_) {
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