package com.calotter.inventory.domain;

import com.calotter.inventory.domain.bo.UserKitchenwareBoToUserKitchenwareMapper;
import com.calotter.inventory.domain.vo.UserKitchenwareVo;
import com.calotter.inventory.domain.vo.UserKitchenwareVoToUserKitchenwareMapper;
import io.github.linpeilie.AutoMapperConfig__50;
import io.github.linpeilie.BaseMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__50.class,
    uses = {UserKitchenwareBoToUserKitchenwareMapper.class,UserKitchenwareVoToUserKitchenwareMapper.class},
    imports = {}
)
public interface UserKitchenwareToUserKitchenwareVoMapper extends BaseMapper<UserKitchenware, UserKitchenwareVo> {
}
