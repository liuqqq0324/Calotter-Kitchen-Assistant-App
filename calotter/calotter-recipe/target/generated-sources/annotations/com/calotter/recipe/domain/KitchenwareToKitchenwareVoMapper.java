package com.calotter.recipe.domain;

import com.calotter.recipe.domain.bo.KitchenwareBoToKitchenwareMapper;
import com.calotter.recipe.domain.vo.KitchenwareVo;
import com.calotter.recipe.domain.vo.KitchenwareVoToKitchenwareMapper;
import io.github.linpeilie.AutoMapperConfig__131;
import io.github.linpeilie.BaseMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__131.class,
    uses = {KitchenwareBoToKitchenwareMapper.class,KitchenwareVoToKitchenwareMapper.class},
    imports = {}
)
public interface KitchenwareToKitchenwareVoMapper extends BaseMapper<Kitchenware, KitchenwareVo> {
}
