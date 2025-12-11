package com.calotter.recipe.domain.vo;

import com.calotter.recipe.domain.Recipe;
import com.calotter.recipe.domain.RecipeToRecipeVoMapper;
import io.github.linpeilie.AutoMapperConfig__131;
import io.github.linpeilie.BaseMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__131.class,
    uses = {RecipeToRecipeVoMapper.class},
    imports = {}
)
public interface RecipeVoToRecipeMapper extends BaseMapper<RecipeVo, Recipe> {
}
