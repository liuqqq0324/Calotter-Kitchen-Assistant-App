import 'package:flutter/material.dart';
import 'package:personal_sous_chef/navigation/main_scaffold.dart';
import 'package:personal_sous_chef/navigation/otter_floating_nav.dart';
import 'package:personal_sous_chef/features/inventory/pages/inventory_page.dart';

// 全局 Keys
// 已从 main.dart 拆分出来

// 1. 定义全局 Key
final GlobalKey<MainScaffoldState> mainScaffoldKey =
    GlobalKey<MainScaffoldState>();

// 🔥 定义 OtterFloatingNav 的 GlobalKey，用于全局触发海獭提示
final GlobalKey<OtterFloatingNavState> otterFloatingNavKey =
    GlobalKey<OtterFloatingNavState>();

// 🔥 定义 InventoryPage 的 GlobalKey，用于在切换 tab 时刷新数据
// 注意：使用 State<InventoryPage> 类型，因为 _InventoryPageState 是私有类
final GlobalKey<State<InventoryPage>> inventoryPageKey =
    GlobalKey<State<InventoryPage>>();

