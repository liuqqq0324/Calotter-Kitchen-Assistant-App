import 'package:shared_preferences/shared_preferences.dart';

/// 海獭提示管理器
/// 管理提示的显示状态，避免重复显示
class OtterTooltipManager {
  static const String _prefix = 'otter_tooltip_';

  /// 检查提示是否已显示过
  static Future<bool> hasShown(String tooltipId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_prefix$tooltipId') ?? false;
  }

  /// 标记提示为已显示
  static Future<void> markAsShown(String tooltipId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_prefix$tooltipId', true);
  }

  /// 重置所有提示（用于测试或重新引导）
  static Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_prefix)) {
        await prefs.remove(key);
      }
    }
  }

  /// 重置特定提示
  static Future<void> reset(String tooltipId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefix$tooltipId');
  }
}

/// 提示ID常量
class OtterTooltipIds {
  static const String firstTimeWelcome = 'first_time_welcome';
  static const String menuGuide = 'menu_guide';
  static const String dragGuide = 'drag_guide';
  static const String homePageHint = 'home_page_hint';
  static const String recipesPageHint = 'recipes_page_hint';
  static const String kitchenPageHint = 'kitchen_page_hint';
  static const String profilePageHint = 'profile_page_hint';
  static const String addItemHint = 'add_item_hint';
}
