package com.calotter.cook.domain.vo;

import com.calotter.cook.domain.RecipeIngredientHistory;
import com.calotter.cook.domain.RecipeIngredientHistoryToRecipeIngredientHistoryVoMapper;
import io.github.linpeilie.AutoMapperConfig__129;
import io.github.linpeilie.BaseMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__129.class,
    uses = {RecipeIngredientHistoryToRecipeIngredientHistoryVoMapper.class},
    imports = {}
)
public interface RecipeIngredientHistoryVoToRecipeIngredientHistoryMapper extends BaseMapper<RecipeIngredientHistoryVo, RecipeIngredientHistory> {
}
