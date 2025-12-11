package org.dromara.system.domain.bo;

import io.github.linpeilie.AutoMapperConfig__137;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysUser;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__137.class,
    uses = {},
    imports = {}
)
public interface SysUserBoToSysUserMapper__1 extends BaseMapper<SysUserBo, SysUser> {
}
