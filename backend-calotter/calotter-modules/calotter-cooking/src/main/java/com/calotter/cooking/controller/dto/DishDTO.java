package com.calotter.cooking.controller.dto;

import com.calotter.cooking.domain.entity.Dish;
import com.calotter.cooking.domain.enums.DifficultyLevel;
import lombok.Builder;
import lombok.Data;

import java.util.List;

/**
 * Dish response DTO.
 *
 * Why: "favorite" is a relationship (household_favorite_dishes), not a persisted Dish attribute.
 * We keep the JSON shape compatible with existing frontend parsing.
 */
@Data
@Builder
public class DishDTO {
    private Long id;
    private String name;
    private String coverImage;
    private String description;

    private Integer totalWeightGram;
    private Integer totalCalories;
    private Double totalProtein;
    private Double totalFat;
    private Double totalCarb;
    private Double totalFiber;

    private Integer cookingTimeMinutes;
    private DifficultyLevel difficulty;

    private List<Dish.CookingStep> steps;
    private List<String> tags;
    private List<Dish.IngredientSnapshot> ingredientSnapshots;

    private boolean favorite;
}


