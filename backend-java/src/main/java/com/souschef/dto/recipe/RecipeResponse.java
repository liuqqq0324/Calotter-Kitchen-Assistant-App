package com.souschef.dto.recipe;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import java.util.List;

@Data
public class RecipeResponse {

    @JsonProperty("recipe_id")
    private String recipeId;

    private String title;

    @JsonProperty("short_description")
    private String shortDescription;

    private Integer servings;

    @JsonProperty("cooking_time_min")
    private Integer cookingTimeMin;

    private String difficulty; // 'easy' / 'medium' / 'hard'

    @JsonProperty("total_calories_estimate")
    private Double totalCaloriesEstimate;

    private List<RecipeIngredientResponse> ingredients;

    private List<RecipeStepResponse> steps;

    private String emoji;
}
