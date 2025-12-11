package com.calotter.recipe.domain;

import com.calotter.recipe.domain.bo.RecipeBoToRecipeMapper;
import com.calotter.recipe.domain.vo.RecipeVo;
import com.calotter.recipe.domain.vo.RecipeVoToRecipeMapper;
import io.github.linpeilie.AutoMapperConfig__131;
import io.github.linpeilie.BaseMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__131.class,
    uses = {RecipeBoToRecipeMapper.class,RecipeVoToRecipeMapper.class},
    imports = {}
)
public interface RecipeToRecipeVoMapper extends BaseMapper<Recipe, RecipeVo> {
}
