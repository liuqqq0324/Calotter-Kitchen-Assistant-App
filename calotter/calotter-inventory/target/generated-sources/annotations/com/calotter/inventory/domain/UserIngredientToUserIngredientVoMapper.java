package com.calotter.inventory.domain;

import com.calotter.inventory.domain.bo.UserIngredientBoToUserIngredientMapper;
import com.calotter.inventory.domain.vo.UserIngredientVo;
import com.calotter.inventory.domain.vo.UserIngredientVoToUserIngredientMapper;
import io.github.linpeilie.AutoMapperConfig__130;
import io.github.linpeilie.BaseMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__130.class,
    uses = {UserIngredientBoToUserIngredientMapper.class,UserIngredientVoToUserIngredientMapper.class},
    imports = {}
)
public interface UserIngredientToUserIngredientVoMapper extends BaseMapper<UserIngredient, UserIngredientVo> {
}
