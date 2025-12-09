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
  final double totalCaloriesEstimate;
  final List<RecipeIngredientModel> ingredients;
  final List<RecipeStepModel> steps;
  final String emoji; // 简单当配图用

  const RecipeModel({
    required this.id,
    required this.title,
    required this.shortDescription,
    required this.servings,
    required this.cookingTimeMin,
    required this.difficulty,
    required this.totalCaloriesEstimate,
    required this.ingredients,
    required this.steps,
    this.emoji = '🍽️',
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
      totalCaloriesEstimate:
          (json['total_calories_estimate'] ?? json['totalCaloriesEstimate'] ?? 0)
                  is num
              ? (json['total_calories_estimate'] ??
                      json['totalCaloriesEstimate'])
                  .toDouble()
              : 0,
      ingredients:
          ingredientsJson.map((e) => RecipeIngredientModel.fromJson(e)).toList(),
      steps: recipesSteps.map((e) => RecipeStepModel.fromJson(e)).toList(),
      emoji: json['emoji']?.toString() ?? '🍽️',
    );
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
