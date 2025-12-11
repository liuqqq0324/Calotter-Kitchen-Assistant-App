package com.calotter.recipe.domain.vo;

import com.calotter.recipe.domain.RecipeIngredient;
import com.calotter.recipe.domain.RecipeIngredientToRecipeIngredientVoMapper;
import io.github.linpeilie.AutoMapperConfig__131;
import io.github.linpeilie.BaseMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__131.class,
    uses = {RecipeIngredientToRecipeIngredientVoMapper.class},
    imports = {}
)
public interface RecipeIngredientVoToRecipeIngredientMapper extends BaseMapper<RecipeIngredientVo, RecipeIngredient> {
}
