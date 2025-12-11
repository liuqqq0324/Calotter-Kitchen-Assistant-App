package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__114;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysMenuBoToSysMenuMapper__3;
import org.dromara.system.domain.vo.SysMenuVo;
import org.dromara.system.domain.vo.SysMenuVoToSysMenuMapper__3;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__114.class,
    uses = {SysMenuVoToSysMenuMapper__3.class,SysMenuBoToSysMenuMapper__3.class},
    imports = {}
)
public interface SysMenuToSysMenuVoMapper__3 extends BaseMapper<SysMenu, SysMenuVo> {
}
