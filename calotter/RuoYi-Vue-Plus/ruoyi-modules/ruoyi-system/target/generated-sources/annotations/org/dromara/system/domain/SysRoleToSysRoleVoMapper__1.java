package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__137;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysRoleBoToSysRoleMapper__1;
import org.dromara.system.domain.vo.SysRoleVo;
import org.dromara.system.domain.vo.SysRoleVoToSysRoleMapper__1;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__137.class,
    uses = {SysRoleVoToSysRoleMapper__1.class,SysRoleBoToSysRoleMapper__1.class},
    imports = {}
)
public interface SysRoleToSysRoleVoMapper__1 extends BaseMapper<SysRole, SysRoleVo> {
}
