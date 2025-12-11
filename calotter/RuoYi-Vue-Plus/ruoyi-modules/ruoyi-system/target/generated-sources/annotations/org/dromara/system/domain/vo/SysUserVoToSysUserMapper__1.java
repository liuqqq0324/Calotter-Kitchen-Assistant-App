package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__137;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysRoleToSysRoleVoMapper__1;
import org.dromara.system.domain.SysUser;
import org.dromara.system.domain.SysUserToSysUserVoMapper__1;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__137.class,
    uses = {SysRoleVoToSysRoleMapper__1.class,SysRoleToSysRoleVoMapper__1.class,SysUserToSysUserVoMapper__1.class},
    imports = {}
)
public interface SysUserVoToSysUserMapper__1 extends BaseMapper<SysUserVo, SysUser> {
}
