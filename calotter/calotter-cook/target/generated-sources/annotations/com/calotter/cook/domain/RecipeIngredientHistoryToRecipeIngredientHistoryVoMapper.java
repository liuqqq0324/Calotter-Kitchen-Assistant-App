package com.calotter.cook.domain;

import com.calotter.cook.domain.bo.RecipeIngredientHistoryBoToRecipeIngredientHistoryMapper;
import com.calotter.cook.domain.vo.RecipeIngredientHistoryVo;
import com.calotter.cook.domain.vo.RecipeIngredientHistoryVoToRecipeIngredientHistoryMapper;
import io.github.linpeilie.AutoMapperConfig__49;
import io.github.linpeilie.BaseMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__49.class,
    uses = {RecipeIngredientHistoryVoToRecipeIngredientHistoryMapper.class,RecipeIngredientHistoryBoToRecipeIngredientHistoryMapper.class},
    imports = {}
)
public interface RecipeIngredientHistoryToRecipeIngredientHistoryVoMapper extends BaseMapper<RecipeIngredientHistory, RecipeIngredientHistoryVo> {
}
