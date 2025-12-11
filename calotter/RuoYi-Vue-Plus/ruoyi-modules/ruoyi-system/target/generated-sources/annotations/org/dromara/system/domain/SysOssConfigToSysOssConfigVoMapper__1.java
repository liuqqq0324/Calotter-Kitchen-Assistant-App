package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__137;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysOssConfigBoToSysOssConfigMapper__1;
import org.dromara.system.domain.vo.SysOssConfigVo;
import org.dromara.system.domain.vo.SysOssConfigVoToSysOssConfigMapper__1;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__137.class,
    uses = {SysOssConfigVoToSysOssConfigMapper__1.class,SysOssConfigBoToSysOssConfigMapper__1.class},
    imports = {}
)
public interface SysOssConfigToSysOssConfigVoMapper__1 extends BaseMapper<SysOssConfig, SysOssConfigVo> {
}
