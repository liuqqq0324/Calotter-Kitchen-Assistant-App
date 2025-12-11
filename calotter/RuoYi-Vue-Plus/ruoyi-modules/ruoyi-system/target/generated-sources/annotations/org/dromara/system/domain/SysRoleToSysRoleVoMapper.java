package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__152;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysRoleBoToSysRoleMapper;
import org.dromara.system.domain.vo.SysRoleVo;
import org.dromara.system.domain.vo.SysRoleVoToSysRoleMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__152.class,
    uses = {SysRoleVoToSysRoleMapper.class,SysRoleBoToSysRoleMapper.class},
    imports = {}
)
public interface SysRoleToSysRoleVoMapper extends BaseMapper<SysRole, SysRoleVo> {
}
