package com.calotter.cook.domain.bo;

import com.calotter.cook.domain.RecipeIngredientHistory;
import com.calotter.common.mybatis.core.domain.BaseEntity;
import com.calotter.common.core.validate.AddGroup;
import com.calotter.common.core.validate.EditGroup;
import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;
import lombok.EqualsAndHashCode;
import jakarta.validation.constraints.*;

/**
 * cms_recipe_ingredient_history;This table stores all associated data regarding which ingredients were consumed for a specific dish prepared by the user. business object cms_recipe_ingredient_history
 *
 * @author Ruoyu Ji
 */
@Data
@EqualsAndHashCode(callSuper = true)
@AutoMapper(target = RecipeIngredientHistory.class, reverseConvertGenerate = false)
public class RecipeIngredientHistoryBo extends BaseEntity {

    /**
     * Session ingredient usage id;Session ingredient usage ID (PK)
     */
    @NotNull(message = "Session ingredient usage id;Session ingredient usage ID (PK) can not be empty", groups = { EditGroup.class })
    private Long id;

    /**
     * Recipe id;History recipe ID (FK, recipe_id -> session.id)
     */
    @NotNull(message = "Recipe id;History recipe ID (FK, recipe_id -> session.id) can not be empty", groups = { AddGroup.class, EditGroup.class })
    private Long recipeId;

    /**
     * Ingredient id;Ingredient ID (FK, ingredient_id -> ingredient.id)
     */
    @NotNull(message = "Ingredient id;Ingredient ID (FK, ingredient_id -> ingredient.id) can not be empty", groups = { AddGroup.class, EditGroup.class })
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
