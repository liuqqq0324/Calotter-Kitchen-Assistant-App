package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__137;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysConfig;
import org.dromara.system.domain.SysConfigToSysConfigVoMapper__1;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__137.class,
    uses = {SysConfigToSysConfigVoMapper__1.class},
    imports = {}
)
public interface SysConfigVoToSysConfigMapper__1 extends BaseMapper<SysConfigVo, SysConfig> {
}
