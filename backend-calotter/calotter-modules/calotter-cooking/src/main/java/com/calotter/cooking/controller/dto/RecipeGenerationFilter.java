package com.calotter.cooking.controller.dto;

import lombok.Data;

import java.util.List;

@Data
public class RecipeGenerationFilter {
    private List<InventoryItem> inventory;
    private CalorieTarget calorieTarget;
    private Integer servings;
    private DietPreferences dietPreferences;
    private GenerationSettings generationSettings;
    private List<String> cookers;
    private List<String> seasonings;

    @Data
    public static class InventoryItem {
        private String name;
        private Double amountValue;
        private String amountUnit;
        private String expiresAt;
    }

    @Data
    public static class CalorieTarget {
        private Double minTotalKcal;
        private Double maxTotalKcal;
    }

    @Data
    public static class DietPreferences {
        private List<String> cuisinePreferences;
        private List<String> tastePreferences;
        private List<String> avoidIngredients;
        private List<String> allergies;
    }

    @Data
    public static class GenerationSettings {
        private Integer dishCount;
        private Integer maxCookingTimeMin;
        private String difficultyTarget;
    }
}
