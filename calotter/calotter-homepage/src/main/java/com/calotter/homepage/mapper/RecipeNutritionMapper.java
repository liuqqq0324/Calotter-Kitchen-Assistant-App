package com.calotter.homepage.mapper;

import com.calotter.homepage.domain.RecipeNutrition;
import com.calotter.homepage.domain.vo.RecipeNutritionVo;
import com.calotter.common.mybatis.core.mapper.BaseMapperPlus;

/**
 * hp_recipe_nutrition;This table stores detailed nutrition information for recipes. mapper interface
 *
 * @author Auto Generated
 */
public interface RecipeNutritionMapper extends BaseMapperPlus<RecipeNutrition, RecipeNutritionVo> {

    /**
     * Find nutrition information by recipe ID
     */
    RecipeNutritionVo selectByRecipeId(Integer recipeId);

}
