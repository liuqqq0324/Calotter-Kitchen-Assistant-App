package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__40;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysMenuBoToSysMenuMapper__14;
import org.dromara.system.domain.vo.SysMenuVo;
import org.dromara.system.domain.vo.SysMenuVoToSysMenuMapper__14;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__40.class,
    uses = {SysMenuVoToSysMenuMapper__14.class,SysMenuBoToSysMenuMapper__14.class},
    imports = {}
)
public interface SysMenuToSysMenuVoMapper__14 extends BaseMapper<SysMenu, SysMenuVo> {
}
