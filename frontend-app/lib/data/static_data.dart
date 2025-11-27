// lib/data/static_data.dart
import 'package:personal_sous_chef/models/ingredient.dart'; // 1. 引入 Model

// 2. 所有合法的食材名称库 (用于搜索补全)
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

// 3. 所有合法的单位选项
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

// 4. 初始库存 mock 数据 (把原来写在 Page 里的搬过来)
// 注意：这里不能用 const，因为 DateTime.now() 是运行时动态的
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
