package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__38;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysMenu;
import org.dromara.system.domain.SysMenuToSysMenuVoMapper__4;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__38.class,
    uses = {SysMenuToSysMenuVoMapper__4.class,SysMenuToSysMenuVoMapper__4.class},
    imports = {}
)
public interface SysMenuVoToSysMenuMapper__4 extends BaseMapper<SysMenuVo, SysMenu> {
}
