package com.calotter.recipe.domain.bo;

import com.calotter.recipe.domain.RecipeIngredient;
import com.calotter.common.mybatis.core.domain.BaseEntity;
import com.calotter.common.core.validate.AddGroup;
import com.calotter.common.core.validate.EditGroup;
import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;
import lombok.EqualsAndHashCode;
import jakarta.validation.constraints.*;

/**
 * rms_recipe_ingredient;Store the ingredient compositions of recipes. business object rms_recipe_ingredient
 *
 * @author Ruoyu Ji
 */
@Data
@EqualsAndHashCode(callSuper = true)
@AutoMapper(target = RecipeIngredient.class, reverseConvertGenerate = false)
public class RecipeIngredientBo extends BaseEntity {

    /**
     * Recipe ingredient id;Recipe ingredient ID (PK)
     */
    @NotNull(message = "Recipe ingredient id;Recipe ingredient ID (PK) can not be empty", groups = { EditGroup.class })
    private Long id;

    /**
     * Recipe id;Recipe id (FK, recipe_id -> recipe.id)
     */
    @NotNull(message = "Recipe id;Recipe id (FK, recipe_id -> recipe.id) can not be empty", groups = { AddGroup.class, EditGroup.class })
    private Long recipeId;

    /**
     * Ingredient id;Ingredient id (FK, ingredient_id -> ingredient.id)
     */
    @NotNull(message = "Ingredient id;Ingredient id (FK, ingredient_id -> ingredient.id) can not be empty", groups = { AddGroup.class, EditGroup.class })
    private Long ingredientId;

    /**
     * Quantity of ingredient;Estimated quantity of ingredients used
     */
    @NotNull(message = "Quantity of ingredient;Estimated quantity of ingredients used can not be empty", groups = { AddGroup.class, EditGroup.class })
    private Double quantity;

    /**
     * Unit of ingredients;Unit of ingredients
     */
    @NotBlank(message = "Unit of ingredients;Unit of ingredients can not be empty", groups = { AddGroup.class, EditGroup.class })
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
