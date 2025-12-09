package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__40;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysRole;
import org.dromara.system.domain.SysRoleToSysRoleVoMapper__14;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__40.class,
    uses = {SysRoleToSysRoleVoMapper__14.class},
    imports = {}
)
public interface SysRoleVoToSysRoleMapper__14 extends BaseMapper<SysRoleVo, SysRole> {
}
