// lib/models/leftover.dart
class Leftover {
  final String id;
  final String dishId; // originalDishId
  final String? dishName; // 菜品名称（从后端获取）
  final int quantityGram; // 当前剩余重量（克）
  final DateTime producedTime; // 制作时间
  final String? coverImage; // 封面图URL（从后端获取）
  final int? caloriesPer100g; // 每100克的卡路里（从后端获取）
  final String? imagePlaceholder; // 图片占位符（如果 coverImage 为空时使用）

  Leftover({
    required this.id,
    required this.dishId,
    this.dishName,
    required this.quantityGram,
    required this.producedTime,
    this.coverImage,
    this.caloriesPer100g,
    this.imagePlaceholder = '🍽️',
  });

  // 计算剩余天数（基于制作时间）
  int get daysSinceProduced {
    return DateTime.now().difference(producedTime).inDays;
  }

  // 判断是否过期（假设剩菜保质期为3天）
  bool get isExpired {
    return daysSinceProduced > 3;
  }

  // 判断是否临期（剩余1天）
  bool get isExpiringSoon {
    return daysSinceProduced >= 2 && daysSinceProduced <= 3;
  }

  // 格式化重量显示
  String get formattedWeight {
    if (quantityGram >= 1000) {
      return '${(quantityGram / 1000).toStringAsFixed(1)}kg';
    }
    return '${quantityGram}g';
  }

  // 计算当前剩余重量的卡路里
  int? get currentCalories {
    if (caloriesPer100g == null) return null;
    return (caloriesPer100g! * quantityGram / 100).round();
  }
}

