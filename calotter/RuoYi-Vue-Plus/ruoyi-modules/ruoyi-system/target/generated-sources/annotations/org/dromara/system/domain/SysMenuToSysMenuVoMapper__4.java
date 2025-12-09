package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__38;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysMenuBoToSysMenuMapper__4;
import org.dromara.system.domain.vo.SysMenuVo;
import org.dromara.system.domain.vo.SysMenuVoToSysMenuMapper__4;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__38.class,
    uses = {SysMenuVoToSysMenuMapper__4.class,SysMenuBoToSysMenuMapper__4.class},
    imports = {}
)
public interface SysMenuToSysMenuVoMapper__4 extends BaseMapper<SysMenu, SysMenuVo> {
}
