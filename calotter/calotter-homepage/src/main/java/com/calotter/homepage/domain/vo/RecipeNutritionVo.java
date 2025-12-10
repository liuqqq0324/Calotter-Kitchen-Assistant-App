package com.calotter.homepage.domain.vo;

import com.calotter.homepage.domain.RecipeNutrition;
import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;

import java.io.Serial;
import java.io.Serializable;
import java.math.BigDecimal;

/**
 * hp_recipe_nutrition;This table stores detailed nutrition information for recipes. view object hp_recipe_nutrition
 *
 * @author Auto Generated
 */
@Data
@AutoMapper(target = RecipeNutrition.class)
public class RecipeNutritionVo implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    private Long id;
    private Integer recipeId;
    private BigDecimal energy;
    private BigDecimal fat;
    private BigDecimal carbohydrates;
    private BigDecimal protein;

}
