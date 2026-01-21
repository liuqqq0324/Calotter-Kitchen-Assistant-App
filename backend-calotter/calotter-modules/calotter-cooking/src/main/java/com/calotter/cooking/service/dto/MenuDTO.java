package com.calotter.cooking.service.dto;

import lombok.Data;

import java.util.List;

@Data
public class MenuDTO {
    private Integer menuId;
    private List<RecipeDTO> recipes;

    @Data
    public static class RecipeDTO {
        private String title;
        private String shortDescription;
        private Integer servings;
        private Integer cookingTimeMin;
        private String difficulty;
        private String category; // 烹饪分类 (STIR_FRY_PAN_FRY, STEAM_BOIL, BRAISE_STEW, COLD_SALAD, SOUP, ROAST_BAKE)
        private NutritionEstimate nutritionEstimate;
        private List<IngredientDTO> ingredients;
        private List<StepDTO> steps;
    }

    @Data
    public static class NutritionEstimate {
        private Double calories;
        private Double proteinG;
        private Double fatG;
        private Double carbsG;
    }

    @Data
    public static class IngredientDTO {
        private String name;
        private Double amountValue;
        private String amountUnit;
        private Boolean isOptional;
        private String sourceType; // INVENTORY / MANUAL_ADD
    }

    @Data
    public static class StepDTO {
        private Integer stepNumber;
        private String instruction;
        private Integer stepTimeMin;
    }
}
