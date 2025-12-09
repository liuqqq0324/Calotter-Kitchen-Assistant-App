package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__40;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysMenu;
import org.dromara.system.domain.SysMenuToSysMenuVoMapper__14;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__40.class,
    uses = {SysMenuToSysMenuVoMapper__14.class,SysMenuToSysMenuVoMapper__14.class},
    imports = {}
)
public interface SysMenuVoToSysMenuMapper__14 extends BaseMapper<SysMenuVo, SysMenu> {
}
