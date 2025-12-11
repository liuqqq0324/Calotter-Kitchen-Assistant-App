package com.calotter.recipe.domain;

import com.calotter.recipe.domain.bo.IngredientBoToIngredientMapper;
import com.calotter.recipe.domain.vo.IngredientVo;
import com.calotter.recipe.domain.vo.IngredientVoToIngredientMapper;
import io.github.linpeilie.AutoMapperConfig__225;
import io.github.linpeilie.BaseMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__225.class,
    uses = {IngredientVoToIngredientMapper.class,IngredientBoToIngredientMapper.class},
    imports = {}
)
public interface IngredientToIngredientVoMapper extends BaseMapper<Ingredient, IngredientVo> {
}
