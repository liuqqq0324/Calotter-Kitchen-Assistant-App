package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__114;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysRoleToSysRoleVoMapper__3;
import org.dromara.system.domain.SysUser;
import org.dromara.system.domain.SysUserToSysUserVoMapper__3;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__114.class,
    uses = {SysRoleVoToSysRoleMapper__3.class,SysRoleToSysRoleVoMapper__3.class,SysUserToSysUserVoMapper__3.class},
    imports = {}
)
public interface SysUserVoToSysUserMapper__3 extends BaseMapper<SysUserVo, SysUser> {
}
