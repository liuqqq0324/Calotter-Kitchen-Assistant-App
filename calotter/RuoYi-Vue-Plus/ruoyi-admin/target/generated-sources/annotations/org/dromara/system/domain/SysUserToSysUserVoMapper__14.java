package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__40;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysUserBoToSysUserMapper__14;
import org.dromara.system.domain.vo.SysRoleVoToSysRoleMapper__14;
import org.dromara.system.domain.vo.SysUserVo;
import org.dromara.system.domain.vo.SysUserVoToSysUserMapper__14;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__40.class,
    uses = {SysRoleVoToSysRoleMapper__14.class,SysRoleToSysRoleVoMapper__14.class,SysUserVoToSysUserMapper__14.class,SysUserBoToSysUserMapper__14.class},
    imports = {}
)
public interface SysUserToSysUserVoMapper__14 extends BaseMapper<SysUser, SysUserVo> {
}
