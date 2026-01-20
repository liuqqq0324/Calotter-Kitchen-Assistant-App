// 家庭相关的纯API调用服务
// 只负责HTTP请求，不包含业务逻辑（如存储householdId等）
// 业务逻辑应在 services/business/household_service.dart 中实现

import 'package:http/http.dart' as http;
import 'package:personal_sous_chef/core/config/api_config.dart';
import 'package:personal_sous_chef/core/constants/api_endpoints.dart';

class HouseholdApiService {
  /// 获取授权请求头
  static Map<String, String> _getHeaders(String? token) {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// 获取当前活跃的家庭
  /// GET /api/household/current?userId={userId}
  static Future<http.Response> getCurrentHousehold({
    required String userId,
    String? token,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}${ApiEndpoints.householdCurrent}?userId=$userId',
    );
    
    return await http.get(url, headers: _getHeaders(token));
  }

  /// 通过用户名或邮箱邀请用户加入厨房
  /// POST /api/household/{householdId}/invite
  static Future<http.Response> inviteUser({
    required int householdId,
    required String usernameOrEmail,
    required String inviterId,
    String? token,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}${ApiEndpoints.householdInvite(householdId)}'
      '?usernameOrEmail=${Uri.encodeComponent(usernameOrEmail)}&inviterId=$inviterId',
    );
    
    return await http.post(url, headers: _getHeaders(token));
  }

  /// 通过邀请码加入厨房
  /// POST /api/household/join
  static Future<http.Response> joinHousehold({
    required String inviteCode,
    required String userId,
    String? token,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}${ApiEndpoints.householdJoin}'
      '?inviteCode=${Uri.encodeComponent(inviteCode)}&userId=$userId',
    );
    
    return await http.post(url, headers: _getHeaders(token));
  }

  /// 用户退出厨房
  /// DELETE /api/household/{householdId}/leave
  static Future<http.Response> leaveHousehold({
    required int householdId,
    required String userId,
    String? token,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}${ApiEndpoints.householdLeave(householdId)}'
      '?userId=$userId',
    );
    
    return await http.delete(url, headers: _getHeaders(token));
  }

  /// owner踢出成员
  /// DELETE /api/household/{householdId}/members/{memberId}
  static Future<http.Response> removeMember({
    required int householdId,
    required int memberId,
    required String ownerId,
    String? token,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}${ApiEndpoints.householdMembers(householdId, memberId)}'
      '?ownerId=$ownerId',
    );
    
    return await http.delete(url, headers: _getHeaders(token));
  }

  /// 切换当前使用的厨房
  /// PUT /api/household/{householdId}/switch
  static Future<http.Response> switchCurrentHousehold({
    required int householdId,
    required String userId,
    String? token,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}${ApiEndpoints.householdSwitch(householdId)}'
      '?userId=$userId',
    );
    
    return await http.put(url, headers: _getHeaders(token));
  }

  /// 获取用户加入的所有厨房列表
  /// GET /api/household/user/{userId}/joined
  static Future<http.Response> getJoinedHouseholds({
    required String userId,
    String? token,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}${ApiEndpoints.householdByUserId(int.parse(userId))}',
    );
    
    return await http.get(url, headers: _getHeaders(token));
  }

  /// 通过邀请码获取厨房信息
  /// GET /api/household/invite/{inviteCode}
  static Future<http.Response> getHouseholdByInviteCode({
    required String inviteCode,
    String? token,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}${ApiEndpoints.householdByInviteCode(inviteCode)}',
    );
    
    return await http.get(url, headers: _getHeaders(token));
  }

  /// 重新生成邀请码
  /// PUT /api/household/{householdId}/regenerate-invite-code
  static Future<http.Response> regenerateInviteCode({
    required int householdId,
    required String ownerId,
    String? token,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}${ApiEndpoints.householdRegenerateInviteCode(householdId)}'
      '?ownerId=$ownerId',
    );
    
    return await http.put(url, headers: _getHeaders(token));
  }
}

