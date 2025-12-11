package com.calotter.cook.mapper;

import com.calotter.cook.domain.RecipeIngredientHistory;
import com.calotter.cook.domain.vo.RecipeIngredientHistoryVo;
import com.calotter.common.mybatis.core.mapper.BaseMapperPlus;

/**
 * cms_recipe_ingredient_history;This table stores all associated data regarding which ingredients were consumed for a specific dish prepared by the user. mapper interface
 *
 * @author Ruoyu Ji
 */
public interface RecipeIngredientHistoryMapper extends BaseMapperPlus<RecipeIngredientHistory, RecipeIngredientHistoryVo> {

}
