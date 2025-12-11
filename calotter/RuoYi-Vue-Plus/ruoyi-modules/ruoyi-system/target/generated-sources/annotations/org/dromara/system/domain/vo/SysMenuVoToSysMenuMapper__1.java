package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__137;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysMenu;
import org.dromara.system.domain.SysMenuToSysMenuVoMapper__1;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__137.class,
    uses = {SysMenuToSysMenuVoMapper__1.class,SysMenuToSysMenuVoMapper__1.class},
    imports = {}
)
public interface SysMenuVoToSysMenuMapper__1 extends BaseMapper<SysMenuVo, SysMenu> {
}
