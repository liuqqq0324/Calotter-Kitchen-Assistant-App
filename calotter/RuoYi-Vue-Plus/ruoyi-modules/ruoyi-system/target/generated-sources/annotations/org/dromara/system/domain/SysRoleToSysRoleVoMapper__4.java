package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__38;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysRoleBoToSysRoleMapper__4;
import org.dromara.system.domain.vo.SysRoleVo;
import org.dromara.system.domain.vo.SysRoleVoToSysRoleMapper__4;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__38.class,
    uses = {SysRoleVoToSysRoleMapper__4.class,SysRoleBoToSysRoleMapper__4.class},
    imports = {}
)
public interface SysRoleToSysRoleVoMapper__4 extends BaseMapper<SysRole, SysRoleVo> {
}
