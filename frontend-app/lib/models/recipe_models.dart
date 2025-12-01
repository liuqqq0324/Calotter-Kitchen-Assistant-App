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
}
