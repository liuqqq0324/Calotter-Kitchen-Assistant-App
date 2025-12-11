package com.calotter.recipe.domain.bo;

import com.calotter.recipe.domain.Ingredient;
import io.github.linpeilie.AutoMapperConfig__225;
import io.github.linpeilie.BaseMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__225.class,
    uses = {},
    imports = {}
)
public interface IngredientBoToIngredientMapper extends BaseMapper<IngredientBo, Ingredient> {
}
