package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__114;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysMenu;
import org.dromara.system.domain.SysMenuToSysMenuVoMapper__3;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__114.class,
    uses = {SysMenuToSysMenuVoMapper__3.class,SysMenuToSysMenuVoMapper__3.class},
    imports = {}
)
public interface SysMenuVoToSysMenuMapper__3 extends BaseMapper<SysMenuVo, SysMenu> {
}
