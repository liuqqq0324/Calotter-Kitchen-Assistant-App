package com.calotter.cook.domain;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.calotter.common.mybatis.core.domain.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.io.Serial;

/**
 * cms_recipe_ingredient_history;This table stores all associated data regarding which ingredients were consumed for a specific dish prepared by the user. object cms_recipe_ingredient_history
 *
 * @author Ruoyu Ji
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("cms_recipe_ingredient_history")
public class RecipeIngredientHistory extends BaseEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    /**
     * Session ingredient usage id;Session ingredient usage ID (PK)
     */
    @TableId(value = "id")
    private Long id;

    /**
     * Recipe id;History recipe ID (FK, recipe_id -> session.id)
     */
    private Long recipeId;

    /**
     * Ingredient id;Ingredient ID (FK, ingredient_id -> ingredient.id)
     */
    private Long ingredientId;

    /**
     * Quantity used;Quantity used for the dish
     */
    private Double quantityUsed;

    /**
     * Unit of ingredient used;Unit for the used ingredient
     */
    private String unit;

    /**
     * Is a substitution ingredient;Whether is a substitution ingredient (e.g., the recipe is beef, but I used pork)
     */
    private Boolean substitution;


}
