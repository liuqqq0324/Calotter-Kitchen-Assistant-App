package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__40;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysConfig;
import org.dromara.system.domain.SysConfigToSysConfigVoMapper__14;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__40.class,
    uses = {SysConfigToSysConfigVoMapper__14.class},
    imports = {}
)
public interface SysConfigVoToSysConfigMapper__14 extends BaseMapper<SysConfigVo, SysConfig> {
}
