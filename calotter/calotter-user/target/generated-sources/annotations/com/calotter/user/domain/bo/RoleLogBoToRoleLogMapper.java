package com.calotter.user.domain.bo;

import com.calotter.user.domain.RoleLog;
import io.github.linpeilie.AutoMapperConfig__226;
import io.github.linpeilie.BaseMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__226.class,
    uses = {},
    imports = {}
)
public interface RoleLogBoToRoleLogMapper extends BaseMapper<RoleLogBo, RoleLog> {
}
