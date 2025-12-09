package com.calotter.recipe.api;

import org.springframework.web.bind.annotation.*;

import java.util.*;

/**
 * RMS public APIs to satisfy documentation formats (success path only).
 */
@RestController
public class RecipeApiController {

    @PostMapping("/api/recipes/generate")
    public GeneratedMenusResponse generateMenus(@RequestBody GenerateMenusRequest req) {
        // Return a fixed example as documentation shows
        GeneratedMenusResponse r = new GeneratedMenusResponse();
        r.menus = new ArrayList<>();
        r.menus.add(sampleMenu(1));
        r.menus.add(sampleMenu(2));
        return r;
    }

    @GetMapping("/api/recipes/preferences/default")
    public DefaultPreferences defaultPreferences() {
        DefaultPreferences d = new DefaultPreferences();
        d.servings = 1;
        d.generation_settings = new GenerationSettings();
        d.generation_settings.dish_count = 1;
        d.generation_settings.max_cooking_time_min = 40;
        d.generation_settings.difficulty_target = "easy";
        d.diet_preferences = new DietPreferences();
        d.diet_preferences.cuisine_preferences = Arrays.asList("chinese", "japanese");
        d.diet_preferences.taste_preferences = Arrays.asList("light");
        d.diet_preferences.avoid_ingredients = new ArrayList<>();
        d.diet_preferences.allergies = new ArrayList<>();
        d.calorie_target = new CalorieTarget();
        d.calorie_target.min_total_kcal = 1500;
        d.calorie_target.max_total_kcal = 1800;
        return d;
    }

    // ===== Sample builders =====
    private Menu sampleMenu(int id) {
        Menu m = new Menu();
        m.menu_id = id;
        Recipe rec = new Recipe();
        if (id == 1) {
            rec.title = "Garlic Butter Chicken with Steamed Broccoli";
            rec.short_description = "Pan-seared chicken thigh with garlic butter sauce and light steamed broccoli.";
            rec.servings = 1;
            rec.cooking_time_min = 30;
            rec.difficulty = "easy";
            rec.total_calories_estimate = 650;
            rec.ingredients = new ArrayList<>();
            rec.ingredients.add(ing("chicken thigh", 200, "g", false, "main"));
            rec.ingredients.add(ing("broccoli", 150, "g", false, "main"));
            rec.ingredients.add(ing("rice", 80, "g", false, "main"));
            rec.ingredients.add(ing("olive oil", 10, "ml", false, "seasoning"));
            rec.ingredients.add(ing("salt", 3, "g", false, "seasoning"));
            rec.ingredients.add(ing("black pepper", 1, "g", true, "seasoning"));
            rec.ingredients.add(ing("soy_sauce", 5, "ml", true, "seasoning"));
            rec.steps = new ArrayList<>();
            rec.steps.add(step(1, "Season the chicken thigh with salt and black pepper.", 5));
            rec.steps.add(step(2, "Pan-fry the chicken with olive oil over medium heat until cooked through.", 15));
            rec.steps.add(step(3, "Steam the broccoli until just tender.", 7));
            rec.steps.add(step(4, "Plate the rice, sliced chicken and broccoli, drizzle with a little soy sauce if desired.", 3));
        } else {
            rec.title = "Light Chicken and Broccoli Rice Bowl";
            rec.short_description = "One-bowl light rice dish with simmered chicken and broccoli.";
            rec.servings = 1;
            rec.cooking_time_min = 25;
            rec.difficulty = "easy";
            rec.total_calories_estimate = 580;
            rec.ingredients = new ArrayList<>();
            rec.ingredients.add(ing("chicken thigh", 180, "g", false, "main"));
            rec.ingredients.add(ing("broccoli", 120, "g", false, "main"));
            rec.ingredients.add(ing("rice", 90, "g", false, "main"));
            rec.ingredients.add(ing("soy_sauce", 8, "ml", false, "seasoning"));
            rec.ingredients.add(ing("salt", 2, "g", false, "seasoning"));
            rec.steps = new ArrayList<>();
            rec.steps.add(step(1, "Cook the rice in the rice cooker according to package instructions.", 15));
            rec.steps.add(step(2, "Stir-fry chicken pieces with a little oil until they change color.", 5));
            rec.steps.add(step(3, "Add broccoli, soy sauce, salt and a splash of water, simmer until broccoli is tender and chicken is cooked through.", 5));
        }
        m.recipes = Collections.singletonList(rec);
        return m;
    }

    private Ingredient ing(String name, int amount_value, String amount_unit, boolean is_optional, String category) {
        Ingredient i = new Ingredient();
        i.name = name;
        i.amount_value = amount_value;
        i.amount_unit = amount_unit;
        i.is_optional = is_optional;
        i.category = category;
        return i;
    }

    private Step step(int n, String instruction, int minutes) {
        Step s = new Step();
        s.step_number = n;
        s.instruction = instruction;
        s.step_time_min = minutes;
        return s;
    }

    // ===== DTOs (match docs casing) =====
    public static class GenerateMenusRequest {
        public List<InventoryItem> inventory;
        public CalorieTarget calorie_target;
        public int servings;
        public DietPreferences diet_preferences;
        public GenerationSettings generation_settings;
        public List<String> cookers;
        public List<String> seasonings;
    }

    public static class InventoryItem {
        public String name;
        public int amount_value;
        public String amount_unit;
        public String expires_at; // nullable in docs
    }

    public static class CalorieTarget {
        public int min_total_kcal;
        public int max_total_kcal;
    }

    public static class DietPreferences {
        public List<String> cuisine_preferences;
        public List<String> taste_preferences;
        public List<String> avoid_ingredients;
        public List<String> allergies;
    }

    public static class GenerationSettings {
        public int dish_count;
        public int max_cooking_time_min;
        public String difficulty_target;
    }

    public static class GeneratedMenusResponse {
        public List<Menu> menus;
    }

    public static class Menu {
        public int menu_id;
        public List<Recipe> recipes;
    }

    public static class Recipe {
        public String title;
        public String short_description;
        public int servings;
        public int cooking_time_min;
        public String difficulty;
        public int total_calories_estimate;
        public List<Ingredient> ingredients;
        public List<Step> steps;
    }

    public static class Ingredient {
        public String name;
        public int amount_value;
        public String amount_unit;
        public boolean is_optional;
        public String category;
    }

    public static class Step {
        public int step_number;
        public String instruction;
        public int step_time_min;
    }

    public static class DefaultPreferences {
        public int servings;
        public GenerationSettings generation_settings;
        public DietPreferences diet_preferences;
        public CalorieTarget calorie_target;
    }
}
