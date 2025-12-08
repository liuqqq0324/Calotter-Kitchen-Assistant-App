package com.souschef.dto.recipe;

import lombok.Data;
import java.util.List;
import java.util.Map;

@Data
public class RecipeGenerateRequest {
    private Integer servings;
    private Integer dishCount;
    private Integer calorieTarget;
    private Integer maxCookingTimeMin;
    private String difficultyTarget;
    private DietPreferences dietPreferences;
    private List<String> cookers;
    
    @Data
    public static class DietPreferences {
        private List<String> allergies;
        private List<String> avoidIngredients;
        private List<String> cuisinePreferences;
        private List<String> tastePreferences;
    }
}

