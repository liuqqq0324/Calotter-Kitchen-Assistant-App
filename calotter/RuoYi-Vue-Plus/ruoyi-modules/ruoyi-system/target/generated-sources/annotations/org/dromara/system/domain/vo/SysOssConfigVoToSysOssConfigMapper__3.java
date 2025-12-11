package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__114;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysOssConfig;
import org.dromara.system.domain.SysOssConfigToSysOssConfigVoMapper__3;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__114.class,
    uses = {SysOssConfigToSysOssConfigVoMapper__3.class},
    imports = {}
)
public interface SysOssConfigVoToSysOssConfigMapper__3 extends BaseMapper<SysOssConfigVo, SysOssConfig> {
}
