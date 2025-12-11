package com.calotter.recipe.domain;

import com.calotter.recipe.domain.bo.RecipeIngredientBoToRecipeIngredientMapper;
import com.calotter.recipe.domain.vo.RecipeIngredientVo;
import com.calotter.recipe.domain.vo.RecipeIngredientVoToRecipeIngredientMapper;
import io.github.linpeilie.AutoMapperConfig__131;
import io.github.linpeilie.BaseMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__131.class,
    uses = {RecipeIngredientBoToRecipeIngredientMapper.class,RecipeIngredientVoToRecipeIngredientMapper.class},
    imports = {}
)
public interface RecipeIngredientToRecipeIngredientVoMapper extends BaseMapper<RecipeIngredient, RecipeIngredientVo> {
}
