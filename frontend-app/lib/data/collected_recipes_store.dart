// lib/data/collected_recipes_store.dart
import 'package:flutter/foundation.dart';
import 'package:personal_sous_chef/data/mock_recipes.dart';
import 'package:personal_sous_chef/models/recipe_models.dart';

/// In-memory store for collected (favorite) recipe menus.
/// Uses a ValueNotifier so UI can listen for updates without a full state management lib.
class CollectedRecipesStore {
  static final ValueNotifier<List<RecipeMenuModel>> favorites =
      ValueNotifier<List<RecipeMenuModel>>([
    // 初始放入一些 mock 收藏，展示在首页
    kMockRecipeMenus[0],
    kMockRecipeMenus[1],
  ]);

  static bool isCollected(RecipeMenuModel menu) {
    return favorites.value.any((m) => m.menuId == menu.menuId);
  }

  static void add(RecipeMenuModel menu) {
    if (isCollected(menu)) return;
    favorites.value = [...favorites.value, menu];
  }

  static void remove(RecipeMenuModel menu) {
    favorites.value =
        favorites.value.where((m) => m.menuId != menu.menuId).toList();
  }

  static void toggle(RecipeMenuModel menu) {
    if (isCollected(menu)) {
      remove(menu);
    } else {
      add(menu);
    }
  }
}
