package com.calotter.recipe.domain;

import com.calotter.recipe.domain.bo.RecipeKitchenwareBoToRecipeKitchenwareMapper;
import com.calotter.recipe.domain.vo.RecipeKitchenwareVo;
import com.calotter.recipe.domain.vo.RecipeKitchenwareVoToRecipeKitchenwareMapper;
import io.github.linpeilie.AutoMapperConfig__131;
import io.github.linpeilie.BaseMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__131.class,
    uses = {RecipeKitchenwareBoToRecipeKitchenwareMapper.class,RecipeKitchenwareVoToRecipeKitchenwareMapper.class},
    imports = {}
)
public interface RecipeKitchenwareToRecipeKitchenwareVoMapper extends BaseMapper<RecipeKitchenware, RecipeKitchenwareVo> {
}
