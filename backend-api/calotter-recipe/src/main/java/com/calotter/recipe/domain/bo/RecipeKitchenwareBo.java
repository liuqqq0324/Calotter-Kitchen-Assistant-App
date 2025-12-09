package com.calotter.recipe.domain.bo;

import com.calotter.recipe.domain.RecipeKitchenware;
import com.calotter.common.mybatis.core.domain.BaseEntity;
import com.calotter.common.core.validate.AddGroup;
import com.calotter.common.core.validate.EditGroup;
import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;
import lombok.EqualsAndHashCode;
import jakarta.validation.constraints.*;

/**
 * rms_recipe_kitchenware;A light-weight association table which defines kitchenware requirements of recipes. business object rms_recipe_kitchenware
 *
 * @author Ruoyu Ji
 */
@Data
@EqualsAndHashCode(callSuper = true)
@AutoMapper(target = RecipeKitchenware.class, reverseConvertGenerate = false)
public class RecipeKitchenwareBo extends BaseEntity {

    /**
     * Recipe kitchenware id;Recipe kitchenware ID (PK)
     */
    @NotNull(message = "Recipe kitchenware id;Recipe kitchenware ID (PK) can not be empty", groups = { EditGroup.class })
    private Long id;

    /**
     * Recipe id;Recipe ID (FK, recipe_id -> recipe.id)
     */
    @NotNull(message = "Recipe id;Recipe ID (FK, recipe_id -> recipe.id) can not be empty", groups = { AddGroup.class, EditGroup.class })
    private Long recipeId;

    /**
     * Kitchenware id;Kitchenware ID (FK, kitchenware_id -> kitchenware.id)
     */
    @NotNull(message = "Kitchenware id;Kitchenware ID (FK, kitchenware_id -> kitchenware.id) can not be empty", groups = { AddGroup.class, EditGroup.class })
    private Long kitchenwareId;

    /**
     * Note;Note (e.g., pre-heat to 200 degrees centigrade)
     */
    private String note;


}
