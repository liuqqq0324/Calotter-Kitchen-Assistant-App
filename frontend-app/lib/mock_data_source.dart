// lib/mock_data_source.dart
import 'package:flutter/material.dart';

// 简化的食材模型，用于 UI 测试
class MockIngredient {
  final String name;
  final String quantity;
  final String unit;
  final int daysLeft;
  final Color categoryColor; // 用于区分类型的颜色标记

  MockIngredient({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.daysLeft,
    required this.categoryColor,
  });
}

// 假数据列表
final List<MockIngredient> mockFridgeItems = [
  MockIngredient(name: "Fresh Salmon", quantity: "500", unit: "g", daysLeft: 2, categoryColor: Colors.orangeAccent),
  MockIngredient(name: "Organic Spinach", quantity: "1", unit: "bag", daysLeft: 4, categoryColor: Colors.green),
  MockIngredient(name: "Hokkaido Milk", quantity: "200", unit: "ml", daysLeft: 1, categoryColor: Colors.blueGrey),
  MockIngredient(name: "Eggs (Large)", quantity: "6", unit: "pcs", daysLeft: 10, categoryColor: Colors.yellow[700]!),
  MockIngredient(name: "Avocado", quantity: "2", unit: "pcs", daysLeft: 3, categoryColor: Colors.green[300]!),
  MockIngredient(name: "Clams (Otter favorite)", quantity: "1", unit: "kg", daysLeft: 1, categoryColor: Colors.brown[300]!),
];

// 定义你们选定的配色板 (Riverbank Palette)
class AppPalette {
  static const Color riverDeepBrown = Color(0xFF6B4F4F);
  static const Color waterBlue = Color(0xFFA1C6EA);
  static const Color seaweedGreen = Color(0xFF4E785E);
  static const Color foamWhite = Color(0xFFE3F2FD); // 背景色
  static const Color appetiteOrange = Color(0xFFF0B27A); // 强调色
}

// 定义全局文本样式（手绘风）
// 注意：你需要确保你的项目 pubspec.yaml 已经引入了 google_fonts 并且在 main.dart 里初始化了
TextStyle get sketchyTextStyle => const TextStyle(fontFamily: 'Caveat', package: 'google_fonts');