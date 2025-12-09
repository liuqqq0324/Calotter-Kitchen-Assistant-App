package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__38;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysRole;
import org.dromara.system.domain.SysRoleToSysRoleVoMapper__4;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__38.class,
    uses = {SysRoleToSysRoleVoMapper__4.class},
    imports = {}
)
public interface SysRoleVoToSysRoleMapper__4 extends BaseMapper<SysRoleVo, SysRole> {
}
