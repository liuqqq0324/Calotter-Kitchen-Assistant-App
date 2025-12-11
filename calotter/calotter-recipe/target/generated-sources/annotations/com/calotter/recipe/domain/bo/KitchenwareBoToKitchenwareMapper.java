package com.calotter.recipe.domain.bo;

import com.calotter.recipe.domain.Kitchenware;
import io.github.linpeilie.AutoMapperConfig__131;
import io.github.linpeilie.BaseMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__131.class,
    uses = {},
    imports = {}
)
public interface KitchenwareBoToKitchenwareMapper extends BaseMapper<KitchenwareBo, Kitchenware> {
}
