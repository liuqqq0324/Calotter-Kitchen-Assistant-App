package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__152;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysMenu;
import org.dromara.system.domain.SysMenuToSysMenuVoMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__152.class,
    uses = {SysMenuToSysMenuVoMapper.class,SysMenuToSysMenuVoMapper.class},
    imports = {}
)
public interface SysMenuVoToSysMenuMapper extends BaseMapper<SysMenuVo, SysMenu> {
}
