// ⚠️ 重构说明：main.dart 已拆分为多个文件
// - SousChefApp 类 → app/app.dart
// - MainScaffold 类 → navigation/main_scaffold.dart
// - 全局 Keys → app/app_keys.dart
// - routeObserver → core/routing/route_observer.dart
// - 主题配置 → core/theme/app_theme.dart
// - 底部导航配置 → navigation/bottom_nav_config.dart

import 'package:personal_sous_chef/app/app.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const SousChefApp());
}

