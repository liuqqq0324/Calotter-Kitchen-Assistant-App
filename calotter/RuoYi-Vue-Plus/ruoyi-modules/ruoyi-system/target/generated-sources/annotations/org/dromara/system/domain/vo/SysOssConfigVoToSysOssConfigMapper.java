package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__35;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysOssConfig;
import org.dromara.system.domain.SysOssConfigToSysOssConfigVoMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__35.class,
    uses = {SysOssConfigToSysOssConfigVoMapper.class},
    imports = {}
)
public interface SysOssConfigVoToSysOssConfigMapper extends BaseMapper<SysOssConfigVo, SysOssConfig> {
}
