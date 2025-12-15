package com.calotter.cooking.service.dto;

import lombok.Data;

import java.util.List;

@Data
public class MenuDTO {
    private Integer menu_id;
    private List<RecipeDTO> recipes;

    @Data
    public static class RecipeDTO {
        private String title;
        private String short_description;
        private Integer servings;
        private Integer cooking_time_min;
        private String difficulty;
        private NutritionEstimate nutrition_estimate;
        private List<IngredientDTO> ingredients;
        private List<StepDTO> steps;
    }

    @Data
    public static class NutritionEstimate {
        private Double calories;
        private Double protein_g;
        private Double fat_g;
        private Double carbs_g;
    }

    @Data
    public static class IngredientDTO {
        private String name;
        private Double amount_value;
        private String amount_unit;
        private Boolean is_optional;
        private String source_type; // INVENTORY / MANUAL_ADD
    }

    @Data
    public static class StepDTO {
        private Integer step_number;
        private String instruction;
        private Integer step_time_min;
    }
}
