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

// ⚠️ 以下代码已拆分到 app/app_keys.dart
// // 1. 定义全局 Key
// final GlobalKey<MainScaffoldState> mainScaffoldKey =
//     GlobalKey<MainScaffoldState>();
//
// // 🔥 定义 InventoryPage 的 GlobalKey，用于在切换 tab 时刷新数据
// // 注意：使用 State<InventoryPage> 类型，因为 _InventoryPageState 是私有类
// final GlobalKey<State<InventoryPage>> inventoryPageKey =
//     GlobalKey<State<InventoryPage>>();
//
// // 2. 定义全局 RouteObserver 用于监听路由变化
// final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
