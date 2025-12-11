package com.calotter.recipe.api;

import org.springframework.web.bind.annotation.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.*;

/**
 * Favorite recipes APIs under /api/users/me/favorite-recipes
 * Success path only, in-memory store for MVP.
 */
@RestController
@RequestMapping("/api/users/me/favorite-recipes")
public class FavoriteRecipesApiController {

    private static final Logger log = LoggerFactory.getLogger(FavoriteRecipesApiController.class);
    private final Map<String, SimpleRecipe> favorites = new LinkedHashMap<>();

    @GetMapping
    public FavoriteListResponse list() {
        log.info("[Favorites] GET list");
        if (favorites.isEmpty()) {
            // seed two examples
            favorites.put("rec_123456", sampleTomatoEgg());
            favorites.put("rec_987654", sampleGarlicButterChicken());
        }
        FavoriteListResponse r = new FavoriteListResponse();
        r.recipes = new ArrayList<>();
        for (Map.Entry<String, SimpleRecipe> e : favorites.entrySet()) {
            SimpleRecipe s = e.getValue();
            FavoriteListItem item = new FavoriteListItem();
            item.recipeId = e.getKey();
            item.title = s.title;
            item.short_description = s.short_description;
            item.servings = s.servings;
            item.cooking_time_min = s.cooking_time_min;
            item.difficulty = s.difficulty;
            item.total_calories_estimate = s.total_calories_estimate;
            r.recipes.add(item);
        }
        return r;
    }

    @GetMapping("/{recipeId}")
    public DetailedRecipe get(@PathVariable String recipeId) {
        log.info("[Favorites] GET detail id={}", recipeId);
        if (!favorites.containsKey(recipeId)) {
            // if not existing, return sample tomato egg with requested id
            DetailedRecipe d = sampleTomatoEggDetailed();
            d.recipeId = recipeId;
            return d;
        }
        SimpleRecipe s = favorites.get(recipeId);
        return fromSimple(recipeId, s);
    }

    @PostMapping
    public AddFavoriteResponse add(@RequestBody AddFavoriteRequest req) {
        String id = UUID.randomUUID().toString().replace("-", "");
        log.info("[Favorites] POST add title={} generatedId={}", req.recipe.title, id);
        SimpleRecipe sr = new SimpleRecipe();
        sr.title = req.recipe.title;
        sr.short_description = req.recipe.short_description;
        sr.servings = req.recipe.servings;
        sr.cooking_time_min = req.recipe.cooking_time_min;
        sr.difficulty = req.recipe.difficulty;
        sr.total_calories_estimate = req.recipe.total_calories_estimate;
        sr.ingredients = req.recipe.ingredients;
        sr.steps = req.recipe.steps;
        favorites.put(id, sr);
        AddFavoriteResponse r = new AddFavoriteResponse();
        r.recipeId = id;
        r.message = "Recipe added to favorites";
        return r;
    }

    @DeleteMapping("/{recipeId}")
    public Message remove(@PathVariable String recipeId) {
        log.info("[Favorites] DELETE id={}", recipeId);
        favorites.remove(recipeId);
        Message r = new Message();
        r.message = "Recipe removed from favorites";
        return r;
    }

    // ===== DTOs matching docs =====
    public static class FavoriteListResponse {
        public List<FavoriteListItem> recipes;
    }

    public static class FavoriteListItem {
        public String recipeId;
        public String title;
        public String short_description;
        public int servings;
        public int cooking_time_min;
        public String difficulty;
        public int total_calories_estimate;
    }

    public static class AddFavoriteRequest {
        public String source;
        public DetailedRecipe recipe;
    }

    public static class AddFavoriteResponse {
        public String recipeId;
        public String message;
    }

    public static class Message {
        public String message;
    }

    public static class Ingredient {
        public String name;
        public int amount_value;
        public String amount_unit;
        public boolean is_optional;
    }

    public static class Step {
        public int step_number;
        public String instruction;
        public int step_time_min;
    }

    public static class DetailedRecipe {
        public String recipeId;
        public String title;
        public String short_description;
        public int servings;
        public int cooking_time_min;
        public String difficulty;
        public int total_calories_estimate;
        public List<Ingredient> ingredients;
        public List<Step> steps;
    }

    // ===== Internal helpers =====
    private SimpleRecipe sampleTomatoEgg() {
        SimpleRecipe s = new SimpleRecipe();
        s.title = "Tomato Egg Stir-fry";
        s.short_description = "Light Chinese-style stir fry with tomato and egg.";
        s.servings = 1;
        s.cooking_time_min = 15;
        s.difficulty = "easy";
        s.total_calories_estimate = 320;
        return s;
    }

    private SimpleRecipe sampleGarlicButterChicken() {
        SimpleRecipe s = new SimpleRecipe();
        s.title = "Garlic Butter Chicken";
        s.short_description = "Pan-seared chicken with garlic butter sauce.";
        s.servings = 1;
        s.cooking_time_min = 30;
        s.difficulty = "medium";
        s.total_calories_estimate = 800;
        return s;
    }

    private DetailedRecipe sampleTomatoEggDetailed() {
        DetailedRecipe d = new DetailedRecipe();
        d.recipeId = "rec_123456";
        d.title = "Tomato Egg Stir-fry";
        d.short_description = "Light Chinese-style stir fry with tomato and egg.";
        d.servings = 1;
        d.cooking_time_min = 15;
        d.difficulty = "easy";
        d.total_calories_estimate = 320;
        d.ingredients = new ArrayList<>();
        Ingredient a = new Ingredient(); a.name = "egg"; a.amount_value = 2; a.amount_unit = "piece"; a.is_optional = false; d.ingredients.add(a);
        Ingredient b = new Ingredient(); b.name = "tomato"; b.amount_value = 150; b.amount_unit = "g"; b.is_optional = false; d.ingredients.add(b);
        Ingredient c = new Ingredient(); c.name = "salt"; c.amount_value = 2; c.amount_unit = "g"; c.is_optional = false; d.ingredients.add(c);
        d.steps = new ArrayList<>();
        Step s1 = new Step(); s1.step_number = 1; s1.instruction = "Beat the eggs with a pinch of salt."; s1.step_time_min = 3; d.steps.add(s1);
        Step s2 = new Step(); s2.step_number = 2; s2.instruction = "Stir-fry tomatoes until soft, then add eggs."; s2.step_time_min = 7; d.steps.add(s2);
        Step s3 = new Step(); s3.step_number = 3; s3.instruction = "Season to taste and serve hot."; s3.step_time_min = 5; d.steps.add(s3);
        return d;
    }

    private DetailedRecipe fromSimple(String id, SimpleRecipe s) {
        DetailedRecipe d = new DetailedRecipe();
        d.recipeId = id;
        d.title = s.title;
        d.short_description = s.short_description;
        d.servings = s.servings;
        d.cooking_time_min = s.cooking_time_min;
        d.difficulty = s.difficulty;
        d.total_calories_estimate = s.total_calories_estimate;
        d.ingredients = s.ingredients != null ? s.ingredients : sampleTomatoEggDetailed().ingredients;
        d.steps = s.steps != null ? s.steps : sampleTomatoEggDetailed().steps;
        return d;
    }

    private static class SimpleRecipe {
        String title;
        String short_description;
        int servings;
        int cooking_time_min;
        String difficulty;
        int total_calories_estimate;
        List<Ingredient> ingredients;
        List<Step> steps;
    }
}
