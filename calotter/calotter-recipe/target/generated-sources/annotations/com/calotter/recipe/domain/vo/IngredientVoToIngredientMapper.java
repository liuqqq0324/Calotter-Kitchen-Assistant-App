package com.calotter.recipe.domain.vo;

import com.calotter.recipe.domain.Ingredient;
import com.calotter.recipe.domain.IngredientToIngredientVoMapper;
import io.github.linpeilie.AutoMapperConfig__51;
import io.github.linpeilie.BaseMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__51.class,
    uses = {IngredientToIngredientVoMapper.class},
    imports = {}
)
public interface IngredientVoToIngredientMapper extends BaseMapper<IngredientVo, Ingredient> {
}
