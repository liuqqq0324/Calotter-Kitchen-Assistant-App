package com.calotter.inventory.domain.vo;

import com.calotter.inventory.domain.UserIngredient;
import com.calotter.inventory.domain.UserIngredientToUserIngredientVoMapper;
import io.github.linpeilie.AutoMapperConfig__50;
import io.github.linpeilie.BaseMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__50.class,
    uses = {UserIngredientToUserIngredientVoMapper.class},
    imports = {}
)
public interface UserIngredientVoToUserIngredientMapper extends BaseMapper<UserIngredientVo, UserIngredient> {
}
