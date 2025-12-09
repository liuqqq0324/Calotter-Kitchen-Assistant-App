package com.calotter.cook.domain.vo;

import com.calotter.cook.domain.RecipeIngredientHistory;
import cn.idev.excel.annotation.ExcelIgnoreUnannotated;
import cn.idev.excel.annotation.ExcelProperty;
import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;

import java.io.Serial;
import java.io.Serializable;


/**
 * cms_recipe_ingredient_history;This table stores all associated data regarding which ingredients were consumed for a specific dish prepared by the user. view object cms_recipe_ingredient_history
 *
 * @author Ruoyu Ji
 */
@Data
@ExcelIgnoreUnannotated
@AutoMapper(target = RecipeIngredientHistory.class)
public class RecipeIngredientHistoryVo implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    /**
     * Session ingredient usage id;Session ingredient usage ID (PK)
     */
    @ExcelProperty(value = "Session ingredient usage id;Session ingredient usage ID (PK)")
    private Long id;

    /**
     * Recipe id;History recipe ID (FK, recipe_id -> session.id)
     */
    @ExcelProperty(value = "Recipe id;History recipe ID (FK, recipe_id -> session.id)")
    private Long recipeId;

    /**
     * Ingredient id;Ingredient ID (FK, ingredient_id -> ingredient.id)
     */
    @ExcelProperty(value = "Ingredient id;Ingredient ID (FK, ingredient_id -> ingredient.id)")
    private Long ingredientId;

    /**
     * Quantity used;Quantity used for the dish
     */
    @ExcelProperty(value = "Quantity used;Quantity used for the dish")
    private Double quantityUsed;

    /**
     * Unit of ingredient used;Unit for the used ingredient
     */
    @ExcelProperty(value = "Unit of ingredient used;Unit for the used ingredient")
    private String unit;

    /**
     * Is a substitution ingredient;Whether is a substitution ingredient (e.g., the recipe is beef, but I used pork)
     */
    @ExcelProperty(value = "Is a substitution ingredient;Whether is a substitution ingredient (e.g., the recipe is beef, but I used pork)")
    private Boolean substitution;


}
