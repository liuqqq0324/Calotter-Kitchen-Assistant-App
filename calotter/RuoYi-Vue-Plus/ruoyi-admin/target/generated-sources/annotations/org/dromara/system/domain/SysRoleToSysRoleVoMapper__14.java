package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__40;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysRoleBoToSysRoleMapper__14;
import org.dromara.system.domain.vo.SysRoleVo;
import org.dromara.system.domain.vo.SysRoleVoToSysRoleMapper__14;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__40.class,
    uses = {SysRoleVoToSysRoleMapper__14.class,SysRoleBoToSysRoleMapper__14.class},
    imports = {}
)
public interface SysRoleToSysRoleVoMapper__14 extends BaseMapper<SysRole, SysRoleVo> {
}
