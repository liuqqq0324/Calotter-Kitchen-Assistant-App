package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__38;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysUserBoToSysUserMapper__4;
import org.dromara.system.domain.vo.SysRoleVoToSysRoleMapper__4;
import org.dromara.system.domain.vo.SysUserVo;
import org.dromara.system.domain.vo.SysUserVoToSysUserMapper__4;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__38.class,
    uses = {SysRoleVoToSysRoleMapper__4.class,SysRoleToSysRoleVoMapper__4.class,SysUserVoToSysUserMapper__4.class,SysUserBoToSysUserMapper__4.class},
    imports = {}
)
public interface SysUserToSysUserVoMapper__4 extends BaseMapper<SysUser, SysUserVo> {
}
