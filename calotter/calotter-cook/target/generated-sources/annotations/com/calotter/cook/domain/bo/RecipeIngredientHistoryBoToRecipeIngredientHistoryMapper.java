package com.calotter.cook.domain.bo;

import com.calotter.cook.domain.RecipeIngredientHistory;
import io.github.linpeilie.AutoMapperConfig__148;
import io.github.linpeilie.BaseMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__148.class,
    uses = {},
    imports = {}
)
public interface RecipeIngredientHistoryBoToRecipeIngredientHistoryMapper extends BaseMapper<RecipeIngredientHistoryBo, RecipeIngredientHistory> {
}
