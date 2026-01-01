// lib/services/household_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:personal_sous_chef/config/api_config.dart';
import 'package:personal_sous_chef/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HouseholdService {
  static const String _householdIdKey = 'household_id';

  /// 获取用户的householdId（当前活跃的家庭）
  /// 优先从本地存储获取（登录时保存），否则从API获取用户当前活跃的家庭
  static Future<int?> getHouseholdId({String? userId}) async {
    try {
      // 1. 优先从本地存储获取（登录时保存的）
      final savedHouseholdId = await AuthService.getHouseholdId();
      if (savedHouseholdId != null && savedHouseholdId.isNotEmpty) {
        final id = int.tryParse(savedHouseholdId);
        if (id != null) {
          return id;
        }
      }

      // 2. 如果本地没有，从API获取用户当前活跃的家庭
      final userIdParam = userId ?? await AuthService.getUserId();
      if (userIdParam == null) {
        print('[HouseholdService] No userId available');
        return null;
      }

      // 调用household API获取用户当前活跃的家庭
      final url = Uri.parse(
        '${ApiConfig.baseUrl}/api/household/current?userId=$userIdParam',
      );
      final token = await AuthService.getToken();

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        print(
          '[HouseholdService] Failed to get current household: ${response.statusCode}',
        );
        return null;
      }

      final data = jsonDecode(response.body);
      Map<String, dynamic>? householdData;

      // 处理Result<T>格式
      if (data is Map && data.containsKey('code')) {
        final code = data['code'] as int;
        if (code != 200) {
          print('[HouseholdService] API returned error: ${data['message']}');
          return null;
        }
        householdData = data['data'] as Map<String, dynamic>?;
      } else if (data is Map) {
        householdData = Map<String, dynamic>.from(data);
      }

      if (householdData == null) {
        print('[HouseholdService] User has no current household');
        return null;
      }

      // 返回当前活跃家庭的ID
      final householdId = householdData['id'] as num?;
      if (householdId != null) {
        final id = householdId.toInt();
        // 保存到本地存储，方便下次使用
        await _saveHouseholdId(id.toString());
        return id;
      }

      return null;
    } catch (e) {
      print('[HouseholdService] Error getting householdId: $e');
      return null;
    }
  }

  /// 保存householdId到本地存储
  static Future<void> _saveHouseholdId(String householdId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_householdIdKey, householdId);
  }

  /// 获取当前用户的initiatorId（即userId）
  /// 注意：FamilyMember已被删除，现在直接使用userId
  static Future<int?> getInitiatorId({String? userId}) async {
    try {
      final userIdParam = userId ?? await AuthService.getUserId();
      if (userIdParam == null) {
        return null;
      }
      return int.tryParse(userIdParam);
    } catch (e) {
      print('[HouseholdService] Error getting initiatorId: $e');
      return null;
    }
  }
}
