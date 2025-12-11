package com.calotter.recipe.domain.vo;

import com.calotter.recipe.domain.RecipeKitchenware;
import com.calotter.recipe.domain.RecipeKitchenwareToRecipeKitchenwareVoMapper;
import io.github.linpeilie.AutoMapperConfig__225;
import io.github.linpeilie.BaseMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__225.class,
    uses = {RecipeKitchenwareToRecipeKitchenwareVoMapper.class},
    imports = {}
)
public interface RecipeKitchenwareVoToRecipeKitchenwareMapper extends BaseMapper<RecipeKitchenwareVo, RecipeKitchenware> {
}
