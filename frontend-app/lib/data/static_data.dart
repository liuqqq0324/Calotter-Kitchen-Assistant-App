// lib/data/static_data.dart
import 'package:flutter/material.dart'; // 需要引入 material 库来使用 IconData
import 'package:personal_sous_chef/models/ingredient.dart';
import 'package:personal_sous_chef/models/cookware.dart'; // 🔥 引入 Cookware 模型

// 1. 食材名称补全库 (保持不变)
const List<String> kAllIngredients = [
  'Apple',
  'Banana',
  'Beef Steak',
  'Bread',
  'Broccoli',
  'Carrot',
  'Cheese',
  'Chicken Breast',
  'Corn',
  'Cucumber',
  'Eggs',
  'Fish',
  'Garlic',
  'Ham',
  'Lettuce',
  'Milk',
  'Mushroom',
  'Onion',
  'Pork',
  'Potato',
  'Rice',
  'Salmon',
  'Shrimp',
  'Tomato',
  'Yogurt',
];

// 2. 单位库 (保持不变)
const List<String> kUnitOptions = [
  'pcs',
  'g',
  'kg',
  'ml',
  'L',
  'blocks',
  'box',
  'bag',
];

// 3. 初始食材库存 (保持不变)
final List<Ingredient> kInitialIngredients = [
  Ingredient(
    name: "Beef Steak",
    expiryDate: DateTime.now().add(const Duration(days: 7)),
    quantity: 500,
    unit: 'g',
    imagePlaceholder: '🥩',
  ),
  Ingredient(
    name: "Milk",
    expiryDate: DateTime.now().subtract(const Duration(days: 2)),
    quantity: 1,
    unit: 'L',
    imagePlaceholder: '🥛',
  ),
  Ingredient(
    name: "Cheese",
    expiryDate: DateTime.now().add(const Duration(days: 2)),
    quantity: 2,
    unit: 'blocks',
    imagePlaceholder: '🧀',
  ),
  Ingredient(
    name: "Eggs",
    expiryDate: DateTime.now().add(const Duration(days: 1)),
    quantity: 12,
    unit: 'pcs',
    imagePlaceholder: '🥚',
  ),
  Ingredient(
    name: "Carrot",
    expiryDate: DateTime.now().add(const Duration(days: 10)),
    quantity: 3,
    unit: 'pcs',
    imagePlaceholder: '🥕',
  ),
];

// 🔥 4. 新增：预设调味料列表 (Pantry Staples)
// 这里我们复用 Cookware 模型，因为结构一样
final List<Cookware> kBasicSeasonings = [
  Cookware(name: 'Salt', icon: Icons.grain, isAvailable: true),
  Cookware(
    name: 'Sugar',
    icon: Icons.check_box_outline_blank,
    isAvailable: true,
  ),
  Cookware(name: 'Black Pepper', icon: Icons.scatter_plot, isAvailable: true),
  Cookware(name: 'Soy Sauce', icon: Icons.invert_colors, isAvailable: true),
  Cookware(name: 'Olive Oil', icon: Icons.opacity, isAvailable: true),
  Cookware(name: 'Vinegar', icon: Icons.science, isAvailable: false),
  Cookware(name: 'Garlic Powder', icon: Icons.spa, isAvailable: false),
  Cookware(name: 'Chili Flakes', icon: Icons.whatshot, isAvailable: false),
  Cookware(name: 'Ketchup', icon: Icons.fastfood, isAvailable: false),
];

// 🔥 5. 新增：预设炊具列表 (Tools)
final List<Cookware> kBasicCookware = [
  Cookware(name: 'Frying Pan', icon: Icons.circle_outlined, isAvailable: true),
  Cookware(name: 'Stock Pot', icon: Icons.coffee, isAvailable: true),
  Cookware(name: 'Chef Knife', icon: Icons.cut, isAvailable: true),
  Cookware(name: 'Cutting Board', icon: Icons.dashboard, isAvailable: true),
  Cookware(name: 'Oven', icon: Icons.microwave, isAvailable: false),
  Cookware(name: 'Blender', icon: Icons.electric_bolt, isAvailable: false),
  Cookware(name: 'Rice Cooker', icon: Icons.rice_bowl, isAvailable: false),
  Cookware(name: 'Whisk', icon: Icons.loop, isAvailable: false),
];
