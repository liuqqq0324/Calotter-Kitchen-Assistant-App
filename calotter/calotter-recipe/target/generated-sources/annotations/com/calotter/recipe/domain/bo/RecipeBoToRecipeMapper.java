package com.calotter.recipe.domain.bo;

import com.calotter.recipe.domain.Recipe;
import io.github.linpeilie.AutoMapperConfig__150;
import io.github.linpeilie.BaseMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__150.class,
    uses = {},
    imports = {}
)
public interface RecipeBoToRecipeMapper extends BaseMapper<RecipeBo, Recipe> {
}
