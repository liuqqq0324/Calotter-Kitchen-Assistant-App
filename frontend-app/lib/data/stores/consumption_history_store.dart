// lib/data/consumption_history_store.dart
// Stub store for meal consumption history before backend is ready.

import 'package:flutter/foundation.dart';
import 'package:personal_sous_chef/data/models/recipe_models.dart';

@immutable
class IngredientUsageRecord {
  final String name;
  final double amountValue;
  final String amountUnit; // 'g', 'ml', 'piece'

  const IngredientUsageRecord({
    required this.name,
    required this.amountValue,
    required this.amountUnit,
  });
}

@immutable
class DishConsumptionRecord {
  final String recipeId;
  final String recipeTitle;
  final double percentEaten; // 0-100
  final List<IngredientUsageRecord> ingredientsUsed;

  const DishConsumptionRecord({
    required this.recipeId,
    required this.recipeTitle,
    required this.percentEaten,
    required this.ingredientsUsed,
  });
}

@immutable
class MealConsumptionRecord {
  final DateTime cookedAt;
  final int menuId;
  final List<DishConsumptionRecord> dishes;

  const MealConsumptionRecord({
    required this.cookedAt,
    required this.menuId,
    required this.dishes,
  });
}

/// In-memory stub store; replace with backend API once ready.
class ConsumptionHistoryStore {
  static final ValueNotifier<List<MealConsumptionRecord>> records =
      ValueNotifier<List<MealConsumptionRecord>>([]);

  static void add(MealConsumptionRecord record) {
    records.value = [...records.value, record];
  }
}
