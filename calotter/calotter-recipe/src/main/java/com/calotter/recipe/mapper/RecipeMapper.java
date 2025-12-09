package com.calotter.recipe.mapper;

import com.calotter.recipe.domain.Recipe;
import com.calotter.recipe.domain.vo.RecipeVo;
import com.calotter.common.mybatis.core.mapper.BaseMapperPlus;

/**
 * rms_recipe;Stores all recipes and the corresponding ingredients. mapper interface
 *
 * @author Ruoyu Ji
 */
public interface RecipeMapper extends BaseMapperPlus<Recipe, RecipeVo> {

}
