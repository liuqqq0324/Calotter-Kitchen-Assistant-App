package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__35;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysUserBoToSysUserMapper;
import org.dromara.system.domain.vo.SysRoleVoToSysRoleMapper;
import org.dromara.system.domain.vo.SysUserVo;
import org.dromara.system.domain.vo.SysUserVoToSysUserMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__35.class,
    uses = {SysRoleVoToSysRoleMapper.class,SysRoleToSysRoleVoMapper.class,SysUserVoToSysUserMapper.class,SysUserBoToSysUserMapper.class},
    imports = {}
)
public interface SysUserToSysUserVoMapper extends BaseMapper<SysUser, SysUserVo> {
}
