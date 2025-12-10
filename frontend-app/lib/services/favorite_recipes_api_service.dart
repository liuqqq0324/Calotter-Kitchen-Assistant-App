// lib/services/favorite_recipes_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:personal_sous_chef/config/api_config.dart';
import 'package:personal_sous_chef/models/recipe_models.dart';

class FavoriteRecipesApiService {
  static Uri _favoritesUrl() =>
      Uri.parse('${ApiConfig.recipeBaseUrl}/api/users/me/favorite-recipes');

  /// Fetch favorite list and hydrate each item with its detail payload.
  static Future<List<RecipeModel>> fetchFavorites() async {
    final listResp = await http.get(_favoritesUrl());
    if (listResp.statusCode != 200) {
      throw Exception(
          'Failed to load favorites: ${listResp.statusCode} ${listResp.body}');
    }

    final data = jsonDecode(listResp.body);
    final recipesJson = (data['recipes'] as List?) ?? [];
    final result = <RecipeModel>[];

    for (final item in recipesJson) {
      final recipeId = item['recipeId']?.toString() ?? '';
      if (recipeId.isEmpty) continue;
      try {
        result.add(await fetchFavoriteDetail(recipeId));
      } catch (e) {
        // Fallback to summary if detail fails so UI still renders something.
        result.add(RecipeModel.fromJson(item));
      }
    }
    return result;
  }

  /// Fetch a single favorite with full detail.
  static Future<RecipeModel> fetchFavoriteDetail(String recipeId) async {
    final url = Uri.parse('${_favoritesUrl()}/$recipeId');
    final resp = await http.get(url);
    if (resp.statusCode != 200) {
      throw Exception(
          'Failed to load favorite detail: ${resp.statusCode} ${resp.body}');
    }
    final data = jsonDecode(resp.body);
    return RecipeModel.fromJson(data);
  }

  /// Add a recipe to favorites and return the saved recipe with server id.
  static Future<RecipeModel> addFavorite(RecipeModel recipe,
      {String source = 'generated_menu'}) async {
    final payload = {
      'source': source,
      'recipe': _recipeToJson(recipe),
    };
    final resp = await http.post(
      _favoritesUrl(),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (resp.statusCode != 200 && resp.statusCode != 201) {
      throw Exception(
          'Failed to add favorite: ${resp.statusCode} ${resp.body}');
    }
    final data = jsonDecode(resp.body);
    final newId = data['recipeId']?.toString();
    return _cloneWithId(recipe, newId);
  }

  /// Remove a favorite by id.
  static Future<void> removeFavorite(String recipeId) async {
    final url = Uri.parse('${_favoritesUrl()}/$recipeId');
    final resp = await http.delete(url);
    if (resp.statusCode != 200 && resp.statusCode != 204) {
      throw Exception(
          'Failed to remove favorite: ${resp.statusCode} ${resp.body}');
    }
  }

  static Map<String, dynamic> _recipeToJson(RecipeModel recipe) {
    return {
      'title': recipe.title,
      'short_description': recipe.shortDescription,
      'servings': recipe.servings,
      'cooking_time_min': recipe.cookingTimeMin,
      'difficulty': recipe.difficulty,
      'total_calories_estimate': recipe.totalCaloriesEstimate,
      'ingredients': recipe.ingredients
          .map((i) => {
                'name': i.name,
                'amount_value': i.amountValue,
                'amount_unit': i.amountUnit,
                'is_optional': i.isOptional,
              })
          .toList(),
      'steps': recipe.steps
          .map((s) => {
                'step_number': s.stepNumber,
                'instruction': s.instruction,
                'step_time_min': s.stepTimeMin,
              })
          .toList(),
    };
  }

  static RecipeModel _cloneWithId(RecipeModel recipe, String? newId) {
    return RecipeModel(
      id: (newId ?? recipe.id),
      title: recipe.title,
      shortDescription: recipe.shortDescription,
      servings: recipe.servings,
      cookingTimeMin: recipe.cookingTimeMin,
      difficulty: recipe.difficulty,
      totalCaloriesEstimate: recipe.totalCaloriesEstimate,
      ingredients: recipe.ingredients,
      steps: recipe.steps,
      emoji: recipe.emoji,
    );
  }
}
