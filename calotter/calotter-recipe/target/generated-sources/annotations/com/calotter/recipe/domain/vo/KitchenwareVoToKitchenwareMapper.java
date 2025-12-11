package com.calotter.recipe.domain.vo;

import com.calotter.recipe.domain.Kitchenware;
import com.calotter.recipe.domain.KitchenwareToKitchenwareVoMapper;
import io.github.linpeilie.AutoMapperConfig__150;
import io.github.linpeilie.BaseMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__150.class,
    uses = {KitchenwareToKitchenwareVoMapper.class},
    imports = {}
)
public interface KitchenwareVoToKitchenwareMapper extends BaseMapper<KitchenwareVo, Kitchenware> {
}
