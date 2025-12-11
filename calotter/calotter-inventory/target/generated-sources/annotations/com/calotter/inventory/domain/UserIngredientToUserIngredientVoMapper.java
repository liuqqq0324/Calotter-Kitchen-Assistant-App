package com.calotter.inventory.domain;

import com.calotter.inventory.domain.bo.UserIngredientBoToUserIngredientMapper;
import com.calotter.inventory.domain.vo.UserIngredientVo;
import com.calotter.inventory.domain.vo.UserIngredientVoToUserIngredientMapper;
import io.github.linpeilie.AutoMapperConfig__149;
import io.github.linpeilie.BaseMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__149.class,
    uses = {UserIngredientVoToUserIngredientMapper.class,UserIngredientBoToUserIngredientMapper.class},
    imports = {}
)
public interface UserIngredientToUserIngredientVoMapper extends BaseMapper<UserIngredient, UserIngredientVo> {
}
