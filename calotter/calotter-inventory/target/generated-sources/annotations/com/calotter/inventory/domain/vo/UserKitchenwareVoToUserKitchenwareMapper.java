package com.calotter.inventory.domain.vo;

import com.calotter.inventory.domain.UserKitchenware;
import com.calotter.inventory.domain.UserKitchenwareToUserKitchenwareVoMapper;
import io.github.linpeilie.AutoMapperConfig__149;
import io.github.linpeilie.BaseMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__149.class,
    uses = {UserKitchenwareToUserKitchenwareVoMapper.class},
    imports = {}
)
public interface UserKitchenwareVoToUserKitchenwareMapper extends BaseMapper<UserKitchenwareVo, UserKitchenware> {
}
