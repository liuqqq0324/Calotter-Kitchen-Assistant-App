package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__40;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysOssConfig;
import org.dromara.system.domain.SysOssConfigToSysOssConfigVoMapper__14;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__40.class,
    uses = {SysOssConfigToSysOssConfigVoMapper__14.class},
    imports = {}
)
public interface SysOssConfigVoToSysOssConfigMapper__14 extends BaseMapper<SysOssConfigVo, SysOssConfig> {
}
