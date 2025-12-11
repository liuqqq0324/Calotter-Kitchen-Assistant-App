package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__137;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysUserBoToSysUserMapper__1;
import org.dromara.system.domain.vo.SysRoleVoToSysRoleMapper__1;
import org.dromara.system.domain.vo.SysUserVo;
import org.dromara.system.domain.vo.SysUserVoToSysUserMapper__1;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__137.class,
    uses = {SysRoleVoToSysRoleMapper__1.class,SysRoleToSysRoleVoMapper__1.class,SysUserVoToSysUserMapper__1.class,SysUserBoToSysUserMapper__1.class},
    imports = {}
)
public interface SysUserToSysUserVoMapper__1 extends BaseMapper<SysUser, SysUserVo> {
}
