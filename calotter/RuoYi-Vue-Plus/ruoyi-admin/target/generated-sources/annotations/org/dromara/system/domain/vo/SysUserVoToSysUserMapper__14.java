package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__40;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysRoleToSysRoleVoMapper__14;
import org.dromara.system.domain.SysUser;
import org.dromara.system.domain.SysUserToSysUserVoMapper__14;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__40.class,
    uses = {SysRoleVoToSysRoleMapper__14.class,SysRoleToSysRoleVoMapper__14.class,SysUserToSysUserVoMapper__14.class},
    imports = {}
)
public interface SysUserVoToSysUserMapper__14 extends BaseMapper<SysUserVo, SysUser> {
}
