package com.calotter.recipe.domain.bo;

import com.calotter.recipe.domain.RecipeKitchenware;
import io.github.linpeilie.AutoMapperConfig__51;
import io.github.linpeilie.BaseMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__51.class,
    uses = {},
    imports = {}
)
public interface RecipeKitchenwareBoToRecipeKitchenwareMapper extends BaseMapper<RecipeKitchenwareBo, RecipeKitchenware> {
}
