import 'package:shared_preferences/shared_preferences.dart';
import 'package:personal_sous_chef/core/config/avatar_config.dart';
import 'package:personal_sous_chef/core/constants/storage_keys.dart';

/// 头像选择服务 - 本地存储
class AvatarService {
  static Future<String> getSelectedAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(StorageKeys.selectedAvatar) ?? AvatarConfig.defaultAvatar;
  }

  static Future<void> setSelectedAvatar(String avatarId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.selectedAvatar, avatarId);
  }
}
