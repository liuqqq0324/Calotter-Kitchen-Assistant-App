package com.souschef.dto.recipe;

import lombok.Data;
import java.util.List;

@Data
public class RecipeResponse {
    private String id;
    private String title;
    private String shortDescription;
    private Integer servings;
    private Integer cookingTimeMin;
    private String difficulty; // 'easy' / 'medium' / 'hard'
    private Double totalCaloriesEstimate;
    private List<RecipeIngredientResponse> ingredients;
    private List<RecipeStepResponse> steps;
    private String emoji;
}

