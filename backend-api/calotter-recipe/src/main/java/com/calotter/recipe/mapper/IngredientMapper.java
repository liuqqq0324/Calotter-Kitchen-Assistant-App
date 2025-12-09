package com.calotter.recipe.mapper;

import com.calotter.recipe.domain.Ingredient;
import com.calotter.recipe.domain.vo.IngredientVo;
import com.calotter.common.mybatis.core.mapper.BaseMapperPlus;

/**
 * rms_ingredient;Stores all ingredients could be used in a recipe. mapper interface
 *
 * @author Ruoyu Ji
 */
public interface IngredientMapper extends BaseMapperPlus<Ingredient, IngredientVo> {

}
