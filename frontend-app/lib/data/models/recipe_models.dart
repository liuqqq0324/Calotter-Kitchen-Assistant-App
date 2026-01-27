// lib/models/recipe_models.dart
import 'package:flutter/foundation.dart';

@immutable
class RecipeStepModel {
  final int stepNumber;
  final String instruction;
  final int stepTimeMin;

  const RecipeStepModel({
    required this.stepNumber,
    required this.instruction,
    required this.stepTimeMin,
  });

  factory RecipeStepModel.fromJson(Map<String, dynamic> json) {
    return RecipeStepModel(
      stepNumber: (json['step_number'] ?? json['stepNumber'] ?? 0) is num
          ? (json['step_number'] ?? json['stepNumber'] ?? 0).toInt()
          : 0,
      instruction: json['instruction']?.toString() ?? '',
      stepTimeMin: (json['step_time_min'] ?? json['stepTimeMin'] ?? 0) is num
          ? (json['step_time_min'] ?? json['stepTimeMin'] ?? 0).toInt()
          : 0,
    );
  }
}

@immutable
class RecipeIngredientModel {
  final String name;
  final double amountValue;
  final String amountUnit; // 'g', 'ml', 'piece'
  final bool isOptional;

  const RecipeIngredientModel({
    required this.name,
    required this.amountValue,
    required this.amountUnit,
    this.isOptional = false,
  });

  factory RecipeIngredientModel.fromJson(Map<String, dynamic> json) {
    return RecipeIngredientModel(
      name: json['name']?.toString() ?? '',
      amountValue: (json['amount_value'] ?? json['amountValue'] ?? 0) is num
          ? (json['amount_value'] ?? json['amountValue']).toDouble()
          : 0,
      amountUnit: json['amount_unit']?.toString() ??
          json['amountUnit']?.toString() ??
          'g',
      isOptional: json['is_optional'] ?? json['isOptional'] ?? false,
    );
  }
}

@immutable
class RecipeModel {
  final String id; // 前端自己用的 id
  final String title;
  final String shortDescription;
  final int servings;
  final int cookingTimeMin;
  final String difficulty; // 'easy' / 'medium' / 'hard'
  final String? category; // 烹饪分类：STIR_FRY_PAN_FRY, STEAM_BOIL, BRAISE_STEW, COLD_SALAD, SOUP, ROAST_BAKE
  final double totalCaloriesEstimate; // 保留用于向后兼容
  final List<RecipeIngredientModel> ingredients;
  final List<RecipeStepModel> steps;
  final String emoji; // 简单当配图用
  
  // 营养字段（跟着后端）
  final int? totalWeightGram;
  final int? totalCalories; // 对应后端 Integer totalCalories
  final double? totalProtein;
  final double? totalFat;
  final double? totalCarb;
  final double? totalFiber;

  const RecipeModel({
    required this.id,
    required this.title,
    required this.shortDescription,
    required this.servings,
    required this.cookingTimeMin,
    required this.difficulty,
    this.category,
    required this.totalCaloriesEstimate,
    required this.ingredients,
    required this.steps,
    this.emoji = '🍽️',
    this.totalWeightGram,
    this.totalCalories,
    this.totalProtein,
    this.totalFat,
    this.totalCarb,
    this.totalFiber,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    final recipesSteps = (json['steps'] as List?) ?? [];
    final ingredientsJson = (json['ingredients'] as List?) ?? [];

    final rawId = (json['id'] ?? json['recipe_id'] ?? json['recipeId'] ?? '').toString();
    final resolvedId = rawId.isNotEmpty
        ? rawId
        : (json['title']?.toString().isNotEmpty == true
            ? 'recipe_${json['title'].toString().hashCode}'
            : 'recipe_${DateTime.now().microsecondsSinceEpoch}');

    // 解析营养字段
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString());
    }
    
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString());
    }

    // 解析 nutritionEstimate（后端返回的嵌套对象）
    final nutritionEstimate = json['nutritionEstimate'] ?? json['nutrition_estimate'];
    double caloriesFromEstimate = 0.0;
    double? proteinFromEstimate;
    double? fatFromEstimate;
    double? carbsFromEstimate;
    
    if (nutritionEstimate is Map) {
      caloriesFromEstimate = parseDouble(nutritionEstimate['calories']) ?? 0.0;
      proteinFromEstimate = parseDouble(nutritionEstimate['proteinG'] ?? nutritionEstimate['protein_g']);
      fatFromEstimate = parseDouble(nutritionEstimate['fatG'] ?? nutritionEstimate['fat_g']);
      carbsFromEstimate = parseDouble(nutritionEstimate['carbsG'] ?? nutritionEstimate['carbs_g']);
    }

    return RecipeModel(
      id: resolvedId,
      title: json['title']?.toString() ?? 'Untitled recipe',
      shortDescription: json['short_description']?.toString() ??
          json['shortDescription']?.toString() ??
          '',
      servings: (json['servings'] ?? 0) is num ? (json['servings'] as num).toInt() : 0,
      cookingTimeMin: (json['cooking_time_min'] ??
                  json['cookingTimeMin'] ??
                  0) is num
          ? (json['cooking_time_min'] ?? json['cookingTimeMin']).toInt()
          : 0,
      difficulty: json['difficulty']?.toString() ?? 'easy',
      category: json['category']?.toString(),
      // 优先使用 nutritionEstimate.calories，如果没有则使用其他字段
      totalCaloriesEstimate: caloriesFromEstimate > 0
          ? caloriesFromEstimate
          : ((json['total_calories_estimate'] ?? json['totalCaloriesEstimate'] ?? 0) is num
              ? (json['total_calories_estimate'] ?? json['totalCaloriesEstimate']).toDouble()
              : 0),
      ingredients:
          ingredientsJson.map((e) => RecipeIngredientModel.fromJson(e)).toList(),
      steps: recipesSteps.map((e) => RecipeStepModel.fromJson(e)).toList(),
      emoji: json['emoji']?.toString() ?? '🍽️',
      // 营养字段（优先使用 nutritionEstimate，如果没有则使用其他字段）
      totalWeightGram: parseInt(json['total_weight_gram'] ?? json['totalWeightGram']),
      totalCalories: parseInt(json['total_calories'] ?? json['totalCalories']) ?? 
                     (caloriesFromEstimate > 0 ? caloriesFromEstimate.toInt() : null),
      totalProtein: parseDouble(json['total_protein'] ?? json['totalProtein']) ?? proteinFromEstimate,
      totalFat: parseDouble(json['total_fat'] ?? json['totalFat']) ?? fatFromEstimate,
      totalCarb: parseDouble(json['total_carb'] ?? json['totalCarb']) ?? carbsFromEstimate,
      totalFiber: parseDouble(json['total_fiber'] ?? json['totalFiber']),
    );
  }

  /// 根据分类获取对应的配图路径
  String get categoryImagePath {
    final String path;
    if (category == null || category!.isEmpty) {
      print("❌ DEBUG: Category is null/empty. Using default.");
      path = 'assets/dish_category/STIR_FRY_PAN_FRY.png';
    } else {
      // trim() 防止后端返回带空格的字符串
      path = 'assets/dish_category/${category!.trim()}.png';
    }
    
    print("🖼️ DEBUG: Loading image from path: [$path] for recipe: $title"); 
    return path;
  }
}

@immutable
class RecipeMenuModel {
  final int menuId; // 1~5
  final List<RecipeModel> recipes;

  const RecipeMenuModel({
    required this.menuId,
    required this.recipes,
  });

  // 方便在卡片上展示一些汇总信息
  int get totalCookingTimeMin {
    if (recipes.isEmpty) return 0;
    // 简单取所有菜里最大的 cookingTimeMin，当成整套的时间
    return recipes.map((r) => r.cookingTimeMin).fold(0, (a, b) => a > b ? a : b);
  }

  double get totalCalories {
    return recipes.fold(0, (sum, r) => sum + r.totalCaloriesEstimate);
  }

  String get difficultySummary {
    // 简单取所有菜的最大难度
    if (recipes.isEmpty) return 'easy';
    if (recipes.any((r) => r.difficulty == 'hard')) return 'hard';
    if (recipes.any((r) => r.difficulty == 'medium')) return 'medium';
    return 'easy';
  }

  factory RecipeMenuModel.fromJson(Map<String, dynamic> json) {
    final recipesJson = (json['recipes'] as List?) ?? [];
    return RecipeMenuModel(
      menuId: (json['menu_id'] ?? json['menuId'] ?? 0) is num
          ? (json['menu_id'] ?? json['menuId']).toInt()
          : 0,
      recipes: recipesJson.map((e) => RecipeModel.fromJson(e)).toList(),
    );
  }
}
