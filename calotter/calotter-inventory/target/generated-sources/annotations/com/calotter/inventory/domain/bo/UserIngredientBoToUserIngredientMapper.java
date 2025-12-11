package com.calotter.inventory.domain.bo;

import com.calotter.inventory.domain.UserIngredient;
import io.github.linpeilie.AutoMapperConfig__149;
import io.github.linpeilie.BaseMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__149.class,
    uses = {},
    imports = {}
)
public interface UserIngredientBoToUserIngredientMapper extends BaseMapper<UserIngredientBo, UserIngredient> {
}
