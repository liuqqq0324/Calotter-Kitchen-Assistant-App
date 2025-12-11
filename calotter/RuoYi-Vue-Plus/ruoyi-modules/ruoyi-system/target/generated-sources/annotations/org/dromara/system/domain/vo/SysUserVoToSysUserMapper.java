package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__35;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysRoleToSysRoleVoMapper;
import org.dromara.system.domain.SysUser;
import org.dromara.system.domain.SysUserToSysUserVoMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__35.class,
    uses = {SysRoleVoToSysRoleMapper.class,SysRoleToSysRoleVoMapper.class,SysUserToSysUserVoMapper.class},
    imports = {}
)
public interface SysUserVoToSysUserMapper extends BaseMapper<SysUserVo, SysUser> {
}
