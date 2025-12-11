package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__114;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysRoleBoToSysRoleMapper__3;
import org.dromara.system.domain.vo.SysRoleVo;
import org.dromara.system.domain.vo.SysRoleVoToSysRoleMapper__3;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__114.class,
    uses = {SysRoleVoToSysRoleMapper__3.class,SysRoleBoToSysRoleMapper__3.class},
    imports = {}
)
public interface SysRoleToSysRoleVoMapper__3 extends BaseMapper<SysRole, SysRoleVo> {
}
