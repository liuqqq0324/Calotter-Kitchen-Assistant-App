package com.calotter.recipe.domain.bo;

import com.calotter.recipe.domain.RecipeIngredient;
import io.github.linpeilie.AutoMapperConfig__150;
import io.github.linpeilie.BaseMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__150.class,
    uses = {},
    imports = {}
)
public interface RecipeIngredientBoToRecipeIngredientMapper extends BaseMapper<RecipeIngredientBo, RecipeIngredient> {
}
