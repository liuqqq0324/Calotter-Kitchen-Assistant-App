// lib/services/household_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:personal_sous_chef/config/api_config.dart';
import 'package:personal_sous_chef/services/auth_service.dart';

class HouseholdService {
  /// 获取用户的householdId
  /// 通过调用user API获取用户信息，然后从FamilyMember中获取householdId
  static Future<int?> getHouseholdId({String? userId}) async {
    try {
      final userIdParam = userId ?? await AuthService.getUserId();
      if (userIdParam == null) {
        return null;
      }

      // 调用user API获取用户信息
      final url = Uri.parse('${ApiConfig.baseUrl}/api/ums/user?id=$userIdParam');
      final response = await http.get(url);

      if (response.statusCode != 200) {
        print('[HouseholdService] Failed to get user info: ${response.statusCode}');
        return null;
      }

      final data = jsonDecode(response.body);
      // 处理Result<T>格式
      Map<String, dynamic> userData;
      if (data is Map && data.containsKey('code')) {
        final code = data['code'] as int;
        if (code != 200) {
          return null;
        }
        userData = data['data'] as Map<String, dynamic>;
      } else {
        userData = data as Map<String, dynamic>;
      }

      // 从userData中获取householdId
      // 注意：实际API返回的字段名可能不同，需要根据实际情况调整
      if (userData.containsKey('householdId')) {
        return (userData['householdId'] as num?)?.toInt();
      }
      if (userData.containsKey('household_id')) {
        return (userData['household_id'] as num?)?.toInt();
      }
      if (userData.containsKey('familyMember')) {
        final familyMember = userData['familyMember'] as Map<String, dynamic>?;
        if (familyMember != null) {
          if (familyMember.containsKey('householdId')) {
            return (familyMember['householdId'] as num?)?.toInt();
          }
          if (familyMember.containsKey('household_id')) {
            return (familyMember['household_id'] as num?)?.toInt();
          }
          if (familyMember.containsKey('household')) {
            final household = familyMember['household'] as Map<String, dynamic>?;
            if (household != null) {
              return (household['id'] as num?)?.toInt();
            }
          }
        }
      }

      // 如果无法获取，返回null
      print('[HouseholdService] Could not find householdId in user data');
      return null;
    } catch (e) {
      print('[HouseholdService] Error getting householdId: $e');
      return null;
    }
  }

  /// 获取当前用户的initiatorId（FamilyMember ID）
  static Future<int?> getInitiatorId({String? userId}) async {
    try {
      final userIdParam = userId ?? await AuthService.getUserId();
      if (userIdParam == null) {
        return null;
      }

      // 调用user API获取用户信息
      final url = Uri.parse('${ApiConfig.baseUrl}/api/ums/user?id=$userIdParam');
      final response = await http.get(url);

      if (response.statusCode != 200) {
        return null;
      }

      final data = jsonDecode(response.body);
      Map<String, dynamic> userData;
      if (data is Map && data.containsKey('code')) {
        final code = data['code'] as int;
        if (code != 200) {
          return null;
        }
        userData = data['data'] as Map<String, dynamic>;
      } else {
        userData = data as Map<String, dynamic>;
      }

      // 从userData中获取familyMemberId
      if (userData.containsKey('familyMemberId')) {
        return (userData['familyMemberId'] as num?)?.toInt();
      }
      if (userData.containsKey('family_member_id')) {
        return (userData['family_member_id'] as num?)?.toInt();
      }
      if (userData.containsKey('familyMember')) {
        final familyMember = userData['familyMember'] as Map<String, dynamic>?;
        if (familyMember != null && familyMember.containsKey('id')) {
          return (familyMember['id'] as num?)?.toInt();
        }
      }

      // 如果无法获取familyMemberId，使用userId作为fallback
      return int.tryParse(userIdParam);
    } catch (e) {
      print('[HouseholdService] Error getting initiatorId: $e');
      return int.tryParse(userIdParam ?? '');
    }
  }
}

