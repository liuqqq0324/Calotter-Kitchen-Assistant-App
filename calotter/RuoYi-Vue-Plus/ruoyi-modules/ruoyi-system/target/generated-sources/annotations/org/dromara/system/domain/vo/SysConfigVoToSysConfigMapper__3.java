package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__114;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysConfig;
import org.dromara.system.domain.SysConfigToSysConfigVoMapper__3;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__114.class,
    uses = {SysConfigToSysConfigVoMapper__3.class},
    imports = {}
)
public interface SysConfigVoToSysConfigMapper__3 extends BaseMapper<SysConfigVo, SysConfig> {
}
