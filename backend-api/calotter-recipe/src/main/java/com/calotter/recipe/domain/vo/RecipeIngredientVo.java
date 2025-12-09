package com.calotter.recipe.domain.vo;

import com.calotter.recipe.domain.RecipeIngredient;
import cn.idev.excel.annotation.ExcelIgnoreUnannotated;
import cn.idev.excel.annotation.ExcelProperty;
import com.calotter.common.excel.annotation.ExcelDictFormat;
import com.calotter.common.excel.convert.ExcelDictConvert;
import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;

import java.io.Serial;
import java.io.Serializable;
import java.util.Date;



/**
 * rms_recipe_ingredient;Store the ingredient compositions of recipes. view object rms_recipe_ingredient
 *
 * @author Ruoyu Ji
 */
@Data
@ExcelIgnoreUnannotated
@AutoMapper(target = RecipeIngredient.class)
public class RecipeIngredientVo implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    /**
     * Recipe ingredient id;Recipe ingredient ID (PK)
     */
    @ExcelProperty(value = "Recipe ingredient id;Recipe ingredient ID (PK)")
    private Long id;

    /**
     * Recipe id;Recipe id (FK, recipe_id -> recipe.id)
     */
    @ExcelProperty(value = "Recipe id;Recipe id (FK, recipe_id -> recipe.id)")
    private Long recipeId;

    /**
     * Ingredient id;Ingredient id (FK, ingredient_id -> ingredient.id)
     */
    @ExcelProperty(value = "Ingredient id;Ingredient id (FK, ingredient_id -> ingredient.id)")
    private Long ingredientId;

    /**
     * Quantity of ingredient;Estimated quantity of ingredients used
     */
    @ExcelProperty(value = "Quantity of ingredient;Estimated quantity of ingredients used")
    private Double quantity;

    /**
     * Unit of ingredients;Unit of ingredients
     */
    @ExcelProperty(value = "Unit of ingredients;Unit of ingredients")
    private String unit;

    /**
     * Processing note;Processing note (e.g., cut into slices, remove skins)
     */
    @ExcelProperty(value = "Processing note;Processing note (e.g., cut into slices, remove skins)")
    private String processingNote;

    /**
     * Is optional;Whether this ingredient is optional
     */
    @ExcelProperty(value = "Is optional;Whether this ingredient is optional")
    private Boolean optional;

    /**
     * Is garnish;Whether this ingredient is garnish
     */
    @ExcelProperty(value = "Is garnish;Whether this ingredient is garnish")
    private Boolean garnish;

    /**
     * Sort of process;Display order
     */
    @ExcelProperty(value = "Sort of process;Display order")
    private Short sort;


}
