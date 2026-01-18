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

  /// 通过用户名或邮箱邀请用户加入厨房
  /// POST /api/household/{householdId}/invite
  static Future<Map<String, dynamic>> inviteUser({
    required int householdId,
    required String usernameOrEmail,
  }) async {
    try {
      final userId = await AuthService.getUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final url = Uri.parse(
        '${ApiConfig.baseUrl}/api/household/$householdId/invite?usernameOrEmail=${Uri.encodeComponent(usernameOrEmail)}&inviterId=$userId',
      );
      final token = await AuthService.getToken();

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['code'] == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Invitation sent',
        };
      } else {
        return {
          'success': false,
          'error': data['message'] ?? 'Invitation failed',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  /// 通过邀请码加入厨房
  /// POST /api/household/join
  static Future<Map<String, dynamic>> joinHousehold({
    required String inviteCode,
  }) async {
    try {
      final userId = await AuthService.getUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final url = Uri.parse(
        '${ApiConfig.baseUrl}/api/household/join?inviteCode=${Uri.encodeComponent(inviteCode)}&userId=$userId',
      );
      final token = await AuthService.getToken();

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['code'] == 200) {
        final householdData = data['data'] as Map<String, dynamic>?;
        if (householdData != null) {
          // 保存新加入的厨房ID（自动切换）
          await _saveHouseholdId(householdData['id'].toString());
        }
        return {
          'success': true,
          'message': data['message'] ?? 'Successfully joined',
          'data': householdData,
        };
      } else {
        return {
          'success': false,
          'error': data['message'] ?? 'Failed to join',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  /// 用户退出厨房
  /// DELETE /api/household/{householdId}/leave
  static Future<Map<String, dynamic>> leaveHousehold({
    required int householdId,
  }) async {
    try {
      final userId = await AuthService.getUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final url = Uri.parse(
        '${ApiConfig.baseUrl}/api/household/$householdId/leave?userId=$userId',
      );
      final token = await AuthService.getToken();

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['code'] == 200) {
        // 如果退出的是当前厨房，清空本地存储
        final currentHouseholdId = await getHouseholdId();
        if (currentHouseholdId == householdId) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove(_householdIdKey);
        }
        return {
          'success': true,
          'message': data['message'] ?? 'Successfully left',
        };
      } else {
        return {
          'success': false,
          'error': data['message'] ?? 'Failed to leave',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  /// owner踢出成员
  /// DELETE /api/household/{householdId}/members/{memberId}
  static Future<Map<String, dynamic>> removeMember({
    required int householdId,
    required int memberId,
  }) async {
    try {
      final userId = await AuthService.getUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final url = Uri.parse(
        '${ApiConfig.baseUrl}/api/household/$householdId/members/$memberId?ownerId=$userId',
      );
      final token = await AuthService.getToken();

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['code'] == 200) {
        return {
          'success': true,
          'message': data['message'] ?? '移除成功',
        };
      } else {
        return {
          'success': false,
          'error': data['message'] ?? '移除失败',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  /// 切换当前使用的厨房
  /// PUT /api/household/{householdId}/switch
  static Future<Map<String, dynamic>> switchCurrentHousehold({
    required int householdId,
  }) async {
    try {
      final userId = await AuthService.getUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final url = Uri.parse(
        '${ApiConfig.baseUrl}/api/household/$householdId/switch?userId=$userId',
      );
      final token = await AuthService.getToken();

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['code'] == 200) {
        final householdData = data['data'] as Map<String, dynamic>?;
        if (householdData != null) {
          // 保存切换后的厨房ID
          await _saveHouseholdId(householdData['id'].toString());
        }
        return {
          'success': true,
          'message': data['message'] ?? '切换成功',
          'data': householdData,
        };
      } else {
        return {
          'success': false,
          'error': data['message'] ?? '切换失败',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  /// 获取当前厨房
  /// GET /api/household/current?userId={userId}
  static Future<Map<String, dynamic>> getCurrentHousehold() async {
    try {
      final userId = await AuthService.getUserId();
      if (userId == null) {
        return {'success': false, 'error': 'User not logged in'};
      }

      final url = Uri.parse(
        '${ApiConfig.baseUrl}/api/household/current?userId=$userId',
      );
      final token = await AuthService.getToken();

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['code'] == 200) {
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'error': data['message'] ?? '获取当前厨房失败',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  /// 获取用户加入的所有厨房列表
  /// GET /api/household/user/{userId}/joined
  static Future<Map<String, dynamic>> getJoinedHouseholds() async {
    try {
      final userId = await AuthService.getUserId();
      if (userId == null) {
        return {'success': false, 'error': 'User not logged in', 'data': []};
      }

      final url = Uri.parse(
        '${ApiConfig.baseUrl}/api/household/user/$userId/joined',
      );
      final token = await AuthService.getToken();

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['code'] == 200) {
        final list = data['data'] as List?;
        return {
          'success': true,
          'data': list?.cast<Map<String, dynamic>>() ?? [],
        };
      } else {
        return {
          'success': false,
          'error': data['message'] ?? '获取厨房列表失败',
          'data': [],
        };
      }
    } catch (e) {
      print('[HouseholdService] Error getting joined households: $e');
      return {'success': false, 'error': 'Network error: $e', 'data': []};
    }
  }

  /// 获取用户ID（返回int类型）
  static Future<int?> getUserId() async {
    final userIdStr = await AuthService.getUserId();
    if (userIdStr == null) return null;
    return int.tryParse(userIdStr);
  }

  /// 通过邀请码获取厨房信息
  /// GET /api/household/invite/{inviteCode}
  static Future<Map<String, dynamic>?> getHouseholdByInviteCode(
      String inviteCode) async {
    try {
      final url = Uri.parse(
        '${ApiConfig.baseUrl}/api/household/invite/${Uri.encodeComponent(inviteCode)}',
      );
      final token = await AuthService.getToken();

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['code'] == 200) {
        return data['data'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      print('[HouseholdService] Error getting household by invite code: $e');
      return null;
    }
  }

  /// 重新生成邀请码
  /// PUT /api/household/{householdId}/regenerate-invite-code
  static Future<Map<String, dynamic>> regenerateInviteCode({
    required int householdId,
  }) async {
    try {
      final userId = await AuthService.getUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final url = Uri.parse(
        '${ApiConfig.baseUrl}/api/household/$householdId/regenerate-invite-code?ownerId=$userId',
      );
      final token = await AuthService.getToken();

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['code'] == 200) {
        return {
          'success': true,
          'message': data['message'] ?? '邀请码已重新生成',
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'error': data['message'] ?? '重新生成失败',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }
}
