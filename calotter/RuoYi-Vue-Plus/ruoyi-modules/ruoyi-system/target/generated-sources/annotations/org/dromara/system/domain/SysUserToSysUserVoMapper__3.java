package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__114;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysUserBoToSysUserMapper__3;
import org.dromara.system.domain.vo.SysRoleVoToSysRoleMapper__3;
import org.dromara.system.domain.vo.SysUserVo;
import org.dromara.system.domain.vo.SysUserVoToSysUserMapper__3;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__114.class,
    uses = {SysRoleVoToSysRoleMapper__3.class,SysRoleToSysRoleVoMapper__3.class,SysUserVoToSysUserMapper__3.class,SysUserBoToSysUserMapper__3.class},
    imports = {}
)
public interface SysUserToSysUserVoMapper__3 extends BaseMapper<SysUser, SysUserVo> {
}
