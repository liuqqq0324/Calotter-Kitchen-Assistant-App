package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__38;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysRoleToSysRoleVoMapper__4;
import org.dromara.system.domain.SysUser;
import org.dromara.system.domain.SysUserToSysUserVoMapper__4;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__38.class,
    uses = {SysRoleVoToSysRoleMapper__4.class,SysRoleToSysRoleVoMapper__4.class,SysUserToSysUserVoMapper__4.class},
    imports = {}
)
public interface SysUserVoToSysUserMapper__4 extends BaseMapper<SysUserVo, SysUser> {
}
