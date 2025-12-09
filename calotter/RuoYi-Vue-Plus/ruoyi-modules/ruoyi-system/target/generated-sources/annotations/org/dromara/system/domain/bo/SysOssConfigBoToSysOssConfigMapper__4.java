package org.dromara.system.domain.bo;

import io.github.linpeilie.AutoMapperConfig__38;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysOssConfig;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__38.class,
    uses = {},
    imports = {}
)
public interface SysOssConfigBoToSysOssConfigMapper__4 extends BaseMapper<SysOssConfigBo, SysOssConfig> {
}
