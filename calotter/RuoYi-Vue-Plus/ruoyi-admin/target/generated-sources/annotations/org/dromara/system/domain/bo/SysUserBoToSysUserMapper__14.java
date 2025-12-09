package org.dromara.system.domain.bo;

import io.github.linpeilie.AutoMapperConfig__40;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysUser;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__40.class,
    uses = {},
    imports = {}
)
public interface SysUserBoToSysUserMapper__14 extends BaseMapper<SysUserBo, SysUser> {
}
