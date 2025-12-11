package com.calotter.homepage.domain;

import com.calotter.common.mybatis.core.domain.BaseEntity;
import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.io.Serial;
import java.math.BigDecimal;

/**
 * hp_recipe_nutrition;This table stores detailed nutrition information for recipes. object hp_recipe_nutrition
 *
 * @author Auto Generated
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName(value = "hp_recipe_nutrition", schema = "sous_chef_hp")
public class RecipeNutrition extends BaseEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    /**
     * Recipe nutrition id;Recipe nutrition ID (PK)
     */
    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /**
     * Recipe id;Recipe ID (FK, recipe_id -> rms_recipe.id)
     */
    private Integer recipeId;

    /**
     * Energy;Energy in kcal per serving
     */
    private BigDecimal energy;

    /**
     * Fat;Fat in grams per serving
     */
    private BigDecimal fat;

    /**
     * Carbohydrates;Carbohydrates in grams per serving
     */
    private BigDecimal carbohydrates;

    /**
     * Protein;Protein in grams per serving
     */
    private BigDecimal protein;

}
