package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__137;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysConfigBoToSysConfigMapper__1;
import org.dromara.system.domain.vo.SysConfigVo;
import org.dromara.system.domain.vo.SysConfigVoToSysConfigMapper__1;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__137.class,
    uses = {SysConfigVoToSysConfigMapper__1.class,SysConfigBoToSysConfigMapper__1.class},
    imports = {}
)
public interface SysConfigToSysConfigVoMapper__1 extends BaseMapper<SysConfig, SysConfigVo> {
}
