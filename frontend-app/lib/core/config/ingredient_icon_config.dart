// lib/core/config/ingredient_icon_config.dart
//
// 标准食材名称 -> 图标资源路径
// 与后端 init-standard-libraries.sql 中 ref_standard_ingredients 的 name/category 对应，
// 资源文件位于 frontend-app/assets/icons/{CATEGORY}/{filename}.png
// 当前端或资源文件名与标准名不一致时，在 [_assetFileNameOverrides] 中单独映射。

const String _iconsBase = 'assets/icons';

/// 标准食材名称 -> 所属分类（与 SQL ref_standard_ingredients.category 一致）
const Map<String, String> _standardNameToCategory = {
  // FRUIT (1001-1031)
  'Apple': 'FRUIT',
  'Apricot': 'FRUIT',
  'Avocado': 'FRUIT',
  'Banana': 'FRUIT',
  'Blackberry': 'FRUIT',
  'Blueberry': 'FRUIT',
  'Cantaloupe': 'FRUIT',
  'Cherry': 'FRUIT',
  'Coconut': 'FRUIT',
  'Dragon-Fruit': 'FRUIT',
  'Grape': 'FRUIT',
  'Guava': 'FRUIT',
  'Kiwifruit': 'FRUIT',
  'Lemon': 'FRUIT',
  'Lime': 'FRUIT',
  'Longan': 'FRUIT',
  'Lychee': 'FRUIT',
  'Mandarin': 'FRUIT',
  'Mango': 'FRUIT',
  'Nectarine': 'FRUIT',
  'Orange': 'FRUIT',
  'Papaya': 'FRUIT',
  'Peach': 'FRUIT',
  'Pear': 'FRUIT',
  'Persimmon': 'FRUIT',
  'Pineapple': 'FRUIT',
  'Plum': 'FRUIT',
  'Pomegranate': 'FRUIT',
  'Raspberry': 'FRUIT',
  'Strawberry': 'FRUIT',
  'Watermelon': 'FRUIT',
  // FRUIT additional (1128-1132)
  'Cranberry': 'FRUIT',
  'Gooseberry': 'FRUIT',
  'Elderberry': 'FRUIT',
  'Figs': 'FRUIT',
  'Dates': 'FRUIT',
  // VEG (1032-1063)
  'Asparagus': 'VEG',
  'Beetroot': 'VEG',
  'Bok-Choy': 'VEG',
  'Broccoli': 'VEG',
  'Cabbage': 'VEG',
  'Capsicum': 'VEG',
  'Carrot': 'VEG',
  'Cauliflower': 'VEG',
  'Celery': 'VEG',
  'Corn': 'VEG',
  'Zucchini': 'VEG',
  'Cucumber': 'VEG',
  'Eggplant': 'VEG',
  'Garlic': 'VEG',
  'Ginger': 'VEG',
  'Green-Pepper': 'VEG',
  'Kale': 'VEG',
  'Leek': 'VEG',
  'Lettuce': 'VEG',
  'Mushroom': 'VEG',
  'Onion': 'VEG',
  'Parsnip': 'VEG',
  'Potato': 'VEG',
  'Pumpkin': 'VEG',
  'Radish': 'VEG',
  'Red-Pepper': 'VEG',
  'Shiitake': 'VEG',
  'Spinach': 'VEG',
  'Spring-Onion': 'VEG',
  'Swede': 'VEG',
  'Sweet-Potato': 'VEG',
  'Tomato': 'VEG',
  // VEG additional (1115-1127)
  'Brussels Sprouts': 'VEG',
  'Artichoke': 'VEG',
  'Arugula': 'VEG',
  'Endive': 'VEG',
  'Fennel': 'VEG',
  'Collard Greens': 'VEG',
  'Swiss Chard': 'VEG',
  'Turnip': 'VEG',
  'Beans': 'VEG',
  'Green Beans': 'VEG',
  'Peas': 'VEG',
  'Edamame': 'VEG',
  'Bean Sprouts': 'VEG',
  // MEAT (1064-1084)
  'Beef': 'MEAT',
  'Chicken-Breast': 'MEAT',
  'Chicken-Leg': 'MEAT',
  'Chicken-Quater': 'MEAT',
  'Chicken-Thigh': 'MEAT',
  'Chicken-Whole': 'MEAT',
  'Chicken-Wing': 'MEAT',
  'Crab': 'MEAT',
  'Eggs': 'MEAT',
  'Lamb': 'MEAT',
  'Minced-Meat': 'MEAT',
  'Mussels': 'MEAT',
  'Pork': 'MEAT',
  'Salmon': 'MEAT',
  'Sausage': 'MEAT',
  'Scallop': 'MEAT',
  'Sea-Bass': 'MEAT',
  'Shrimp': 'MEAT',
  'Snapper': 'MEAT',
  'Squid': 'MEAT',
  'Tuna': 'MEAT',
  // MEAT additional (1105-1114)
  'Bacon': 'MEAT',
  'Ham': 'MEAT',
  'Turkey': 'MEAT',
  'Duck': 'MEAT',
  'Ground Beef': 'MEAT',
  'Ground Turkey': 'MEAT',
  'Ground Pork': 'MEAT',
  'Lobster': 'MEAT',
  'Clams': 'MEAT',
  'Oysters': 'MEAT',
  // GRAIN (1085-1092)
  'Bagel': 'GRAIN',
  'Brown-rice': 'GRAIN',
  'Chickpea': 'GRAIN',
  'Lentil': 'GRAIN',
  'Millet': 'GRAIN',
  'Oats': 'GRAIN',
  'Pasta': 'GRAIN',
  'White-Rice': 'GRAIN',
  // DAIRY (1093-1094, 1097-1104, 1140)
  'Butter': 'DAIRY',
  'Milk': 'DAIRY',
  'Yogurt': 'DAIRY',
  'Greek Yogurt': 'DAIRY',
  'Cheddar Cheese': 'DAIRY',
  'Mozzarella Cheese': 'DAIRY',
  'Parmesan Cheese': 'DAIRY',
  'Cream Cheese': 'DAIRY',
  'Sour Cream': 'DAIRY',
  'Cottage Cheese': 'DAIRY',
  'Ice Cream': 'DAIRY',
  // OTHER (1095-1096, 1133-1139)
  'Sesame-Seeds': 'OTHER',
  'Tofu': 'OTHER',
  'Olives': 'OTHER',
  'Capers': 'OTHER',
  'Sun-Dried Tomatoes': 'OTHER',
  'Roasted Red Peppers': 'OTHER',
  'Frozen Vegetables': 'OTHER',
  'Frozen Fruits': 'OTHER',
  'Frozen Berries': 'OTHER',
};

/// 标准名称 -> 资源文件名（仅当与标准名不一致时填写，如拼写/资源命名差异）
/// 注意：资源文件名已更正为标准名称，此映射暂时为空
const Map<String, String> _assetFileNameOverrides = {
  // 所有资源文件名已与标准名称一致，无需特殊映射
};

/// 根据标准食材名称获取图标资源路径；无对应资源时返回 null。
/// [standardIngredientName] 应与后端 ref_standard_ingredients.name 一致（如 "Chicken-Whole"）。
String? getIngredientIconPath(String? standardIngredientName) {
  if (standardIngredientName == null || standardIngredientName.isEmpty) {
    return null;
  }
  final category = _standardNameToCategory[standardIngredientName];
  if (category == null) return null;
  final fileName =
      _assetFileNameOverrides[standardIngredientName] ??
      '$standardIngredientName.png';
  return '$_iconsBase/$category/$fileName';
}

/// 默认占位图（无匹配标准食材时使用）
const String defaultIngredientIconPath = '$_iconsBase/Default-Ingredient.png';
