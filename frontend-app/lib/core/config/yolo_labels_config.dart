// lib/config/yolo_labels_config.dart
//
// YOLO model labels configuration
// Labels must strictly match the model's data.yaml configuration (97 classes including '-')
// Order: 0='-', 1='Apple', 2='Apricot', ..., 96='White-Rice'
//
// Model configuration reference:
// nc: 97
// names: ['-', 'Apple', 'Apricot', ..., 'White-Rice']

/// List of all recognizable ingredient labels from the YOLO model
/// This list must match the model's data.yaml configuration exactly
const List<String> yoloLabels = [
  '-',
  'Apple',
  'Apricot',
  'Asparagus',
  'Avocado',
  'Bagel',
  'Banana',
  'Beef',
  'Beetroot',
  'Blackberry',
  'Blueberry',
  'Bok-Choy',
  'Broccoli',
  'Brown-rice',
  'Butter',
  'Cabbage',
  'Cantaloupe',
  'Capsicum',
  'Carrot',
  'Cauliflower',
  'Celery',
  'Cherry',
  'Chicken-Breast',
  'Chicken-Leg',
  'Chicken-Quater',
  'Chicken-Thigh',
  'Chicken-Whole',
  'Chicken-Wing',
  'Chickpea',
  'Coconut',
  'Corn',
  'Courgette',
  'Crab',
  'Cucumber',
  'Dragon-Fruit',
  'Eggplant',
  'Eggs',
  'Garlic',
  'Ginger',
  'Grape',
  'Green-Pepper',
  'Guava',
  'Kale',
  'Kiwifruit',
  'Lamb',
  'Leek',
  'Lemon',
  'Lentil',
  'Lettuce',
  'Lime',
  'Longan',
  'Lychee',
  'Mandarin',
  'Mango',
  'Milk',
  'Millet',
  'Minced-Meat',
  'Mushroom',
  'Mussels',
  'Nectarine',
  'Oats',
  'Onion',
  'Orange',
  'Papaya',
  'Parsnip',
  'Pasta',
  'Peach',
  'Pear',
  'Persimmon',
  'Pineapple',
  'Plum',
  'Pomegranate',
  'Pork',
  'Potato',
  'Pumpkin',
  'Radish',
  'Raspberry',
  'Red-Pepper',
  'Salmon',
  'Sausage',
  'Scallop',
  'Sea-Bass',
  'Sesame-Seeds',
  'Shiitake',
  'Shrimp',
  'Snapper',
  'Spinach',
  'Spring-Onion',
  'Squid',
  'Strawberry',
  'Swede',
  'Sweet-Potato',
  'Tofu',
  'Tomato',
  'Tuna',
  'Watermelon',
  'White-Rice',
];

/// Total number of classes in the YOLO model (including '-' placeholder)
const int yoloClassCount = 97;

/// Placeholder class index (should be filtered out during post-processing)
const int placeholderClassIndex = 0;

/// Placeholder class label
const String placeholderLabel = '-';

