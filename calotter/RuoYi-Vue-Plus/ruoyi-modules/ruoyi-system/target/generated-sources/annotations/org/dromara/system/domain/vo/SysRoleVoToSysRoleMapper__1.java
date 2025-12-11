package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__137;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysRole;
import org.dromara.system.domain.SysRoleToSysRoleVoMapper__1;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__137.class,
    uses = {SysRoleToSysRoleVoMapper__1.class},
    imports = {}
)
public interface SysRoleVoToSysRoleMapper__1 extends BaseMapper<SysRoleVo, SysRole> {
}
