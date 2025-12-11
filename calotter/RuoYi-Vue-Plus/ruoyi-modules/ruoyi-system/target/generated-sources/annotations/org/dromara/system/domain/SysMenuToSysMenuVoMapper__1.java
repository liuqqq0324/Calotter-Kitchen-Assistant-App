package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__137;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysMenuBoToSysMenuMapper__1;
import org.dromara.system.domain.vo.SysMenuVo;
import org.dromara.system.domain.vo.SysMenuVoToSysMenuMapper__1;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__137.class,
    uses = {SysMenuVoToSysMenuMapper__1.class,SysMenuBoToSysMenuMapper__1.class},
    imports = {}
)
public interface SysMenuToSysMenuVoMapper__1 extends BaseMapper<SysMenu, SysMenuVo> {
}
