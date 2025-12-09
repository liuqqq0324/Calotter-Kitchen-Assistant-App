package com.calotter.recipe.domain;

import com.calotter.common.mybatis.core.domain.BaseEntity;
import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.io.Serial;

/**
 * rms_recipe_ingredient;Store the ingredient compositions of recipes. object rms_recipe_ingredient
 *
 * @author Ruoyu Ji
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("rms_recipe_ingredient")
public class RecipeIngredient extends BaseEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    /**
     * Recipe ingredient id;Recipe ingredient ID (PK)
     */
    @TableId(value = "id")
    private Long id;

    /**
     * Recipe id;Recipe id (FK, recipe_id -> recipe.id)
     */
    private Long recipeId;

    /**
     * Ingredient id;Ingredient id (FK, ingredient_id -> ingredient.id)
     */
    private Long ingredientId;

    /**
     * Quantity of ingredient;Estimated quantity of ingredients used
     */
    private Double quantity;

    /**
     * Unit of ingredients;Unit of ingredients
     */
    private String unit;

    /**
     * Processing note;Processing note (e.g., cut into slices, remove skins)
     */
    private String processingNote;

    /**
     * Is optional;Whether this ingredient is optional
     */
    private Boolean optional;

    /**
     * Is garnish;Whether this ingredient is garnish
     */
    private Boolean garnish;

    /**
     * Sort of process;Display order
     */
    private Short sort;


}
