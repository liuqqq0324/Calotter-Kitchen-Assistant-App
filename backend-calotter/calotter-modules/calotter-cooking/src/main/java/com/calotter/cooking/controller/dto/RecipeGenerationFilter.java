package com.calotter.cooking.controller.dto;

import lombok.Data;

import java.util.List;

@Data
public class RecipeGenerationFilter {
    private List<InventoryItem> inventory;
    private CalorieTarget calorie_target;
    private Integer servings;
    private DietPreferences diet_preferences;
    private GenerationSettings generation_settings;
    private List<String> cookers;
    private List<String> seasonings;

    @Data
    public static class InventoryItem {
        private String name;
        private Double amount_value;
        private String amount_unit;
        private String expires_at;
    }

    @Data
    public static class CalorieTarget {
        private Double min_total_kcal;
        private Double max_total_kcal;
    }

    @Data
    public static class DietPreferences {
        private List<String> cuisine_preferences;
        private List<String> taste_preferences;
        private List<String> avoid_ingredients;
        private List<String> allergies;
    }

    @Data
    public static class GenerationSettings {
        private Integer dish_count;
        private Integer max_cooking_time_min;
        private String difficulty_target;
    }
}
