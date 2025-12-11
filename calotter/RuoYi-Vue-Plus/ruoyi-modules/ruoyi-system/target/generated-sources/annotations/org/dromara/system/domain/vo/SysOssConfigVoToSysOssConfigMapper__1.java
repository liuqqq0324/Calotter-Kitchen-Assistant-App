package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__137;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysOssConfig;
import org.dromara.system.domain.SysOssConfigToSysOssConfigVoMapper__1;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__137.class,
    uses = {SysOssConfigToSysOssConfigVoMapper__1.class},
    imports = {}
)
public interface SysOssConfigVoToSysOssConfigMapper__1 extends BaseMapper<SysOssConfigVo, SysOssConfig> {
}
