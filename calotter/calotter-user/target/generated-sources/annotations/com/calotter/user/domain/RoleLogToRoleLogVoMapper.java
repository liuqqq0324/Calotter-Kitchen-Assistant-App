package com.calotter.user.domain;

import com.calotter.user.domain.bo.RoleLogBoToRoleLogMapper;
import com.calotter.user.domain.vo.RoleLogVo;
import com.calotter.user.domain.vo.RoleLogVoToRoleLogMapper;
import io.github.linpeilie.AutoMapperConfig__52;
import io.github.linpeilie.BaseMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__52.class,
    uses = {RoleLogVoToRoleLogMapper.class,RoleLogBoToRoleLogMapper.class},
    imports = {}
)
public interface RoleLogToRoleLogVoMapper extends BaseMapper<RoleLog, RoleLogVo> {
}
