package com.calotter.user.domain.vo;

import com.calotter.user.domain.RoleLog;
import com.calotter.user.domain.RoleLogToRoleLogVoMapper;
import io.github.linpeilie.AutoMapperConfig__52;
import io.github.linpeilie.BaseMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__52.class,
    uses = {RoleLogToRoleLogVoMapper.class},
    imports = {}
)
public interface RoleLogVoToRoleLogMapper extends BaseMapper<RoleLogVo, RoleLog> {
}
