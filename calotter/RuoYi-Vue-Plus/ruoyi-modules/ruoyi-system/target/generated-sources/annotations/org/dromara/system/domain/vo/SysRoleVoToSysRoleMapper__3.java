package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__114;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysRole;
import org.dromara.system.domain.SysRoleToSysRoleVoMapper__3;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__114.class,
    uses = {SysRoleToSysRoleVoMapper__3.class},
    imports = {}
)
public interface SysRoleVoToSysRoleMapper__3 extends BaseMapper<SysRoleVo, SysRole> {
}
