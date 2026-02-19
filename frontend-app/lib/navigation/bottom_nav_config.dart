import 'package:flutter/material.dart';

// 底部导航栏配置
// 已从 main.dart 拆分出来

class BottomNavConfig {
  static const List<NavigationDestination> destinations =
      <NavigationDestination>[
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.menu_book_outlined),
          selectedIcon: Icon(Icons.menu_book),
          label: 'Recipes',
        ),
        NavigationDestination(
          icon: Icon(Icons.add_outlined, size: 24),
          selectedIcon: Icon(Icons.add, size: 24),
          label: 'Add',
        ),
        NavigationDestination(
          icon: Icon(Icons.kitchen_outlined),
          selectedIcon: Icon(Icons.kitchen),
          label: 'Kitchen',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Me',
        ),
      ];
}
