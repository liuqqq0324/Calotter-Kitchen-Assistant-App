// lib/data/collected_recipes_store.dart
// Favorite store now works at recipe level, not menu level.

import 'package:flutter/foundation.dart';
import 'package:personal_sous_chef/models/recipe_models.dart';

class CollectedRecipesStore {
  static final ValueNotifier<List<RecipeModel>> favorites =
      ValueNotifier<List<RecipeModel>>([]);

  static bool isCollected(RecipeModel recipe) {
    return favorites.value.any((r) => r.id == recipe.id);
  }

  static void add(RecipeModel recipe) {
    if (isCollected(recipe)) return;
    favorites.value = [...favorites.value, recipe];
  }

  static void remove(RecipeModel recipe) {
    favorites.value =
        favorites.value.where((r) => r.id != recipe.id).toList();
  }

  static void toggle(RecipeModel recipe) {
    if (isCollected(recipe)) {
      remove(recipe);
    } else {
      add(recipe);
    }
  }
}
