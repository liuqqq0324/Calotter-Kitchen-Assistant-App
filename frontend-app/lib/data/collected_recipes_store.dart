// lib/data/collected_recipes_store.dart
// Favorite store now works at recipe level, not menu level.

import 'package:flutter/foundation.dart';
import 'package:personal_sous_chef/models/recipe_models.dart';
import 'package:personal_sous_chef/services/favorite_recipes_api_service.dart';

class CollectedRecipesStore {
  static final ValueNotifier<List<RecipeModel>> favorites =
      ValueNotifier<List<RecipeModel>>([]);

  static Future<void> fetchFromServer({required int householdId}) async {
    print('[CollectedStore] Fetching favorites from server...');
    final list = await FavoriteRecipesApiService.fetchFavorites(householdId: householdId);
    favorites.value = list;
  }

  static bool isCollected(RecipeModel recipe) {
    return favorites.value.any((r) => r.id == recipe.id);
  }

  static Future<RecipeModel> add(RecipeModel recipe, {required int householdId}) async {
    if (isCollected(recipe)) {
      return favorites.value.firstWhere(
        (r) => r.id == recipe.id,
        orElse: () => recipe,
      );
    }
    print('[CollectedStore] Adding favorite ${recipe.title}');
    final saved = await FavoriteRecipesApiService.addFavorite(recipe, householdId: householdId);
    favorites.value = [...favorites.value, saved];
    return saved;
  }

  static Future<void> remove(RecipeModel recipe, {required int householdId}) async {
    print('[CollectedStore] Removing favorite ${recipe.title}');
    final result = await FavoriteRecipesApiService.toggleFavorite(recipe, householdId: householdId);
    if (result == null) {
      // 已取消收藏
      favorites.value = favorites.value.where((r) => r.id != recipe.id).toList();
    }
  }

  static Future<RecipeModel?> toggle(RecipeModel recipe, {required int householdId}) async {
    if (isCollected(recipe)) {
      await remove(recipe, householdId: householdId);
      return null;
    } else {
      return await add(recipe, householdId: householdId);
    }
  }

  static String _resolveId(RecipeModel recipe) {
    if (recipe.id.isNotEmpty) return recipe.id;
    // Fall back to title hash if we somehow got an empty id.
    return 'recipe_${recipe.title.hashCode}';
  }
}
