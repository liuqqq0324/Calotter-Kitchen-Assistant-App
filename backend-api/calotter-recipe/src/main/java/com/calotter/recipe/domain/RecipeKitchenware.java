package com.calotter.recipe.domain;

import com.calotter.common.mybatis.core.domain.BaseEntity;
import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.io.Serial;

/**
 * rms_recipe_kitchenware;A light-weight association table which defines kitchenware requirements of recipes. object rms_recipe_kitchenware
 *
 * @author Ruoyu Ji
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("rms_recipe_kitchenware")
public class RecipeKitchenware extends BaseEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    /**
     * Recipe kitchenware id;Recipe kitchenware ID (PK)
     */
    @TableId(value = "id")
    private Long id;

    /**
     * Recipe id;Recipe ID (FK, recipe_id -> recipe.id)
     */
    private Long recipeId;

    /**
     * Kitchenware id;Kitchenware ID (FK, kitchenware_id -> kitchenware.id)
     */
    private Long kitchenwareId;

    /**
     * Note;Note (e.g., pre-heat to 200 degrees centigrade)
     */
    private String note;


}
