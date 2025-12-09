package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__40;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysOssConfigBoToSysOssConfigMapper__14;
import org.dromara.system.domain.vo.SysOssConfigVo;
import org.dromara.system.domain.vo.SysOssConfigVoToSysOssConfigMapper__14;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__40.class,
    uses = {SysOssConfigBoToSysOssConfigMapper__14.class,SysOssConfigVoToSysOssConfigMapper__14.class},
    imports = {}
)
public interface SysOssConfigToSysOssConfigVoMapper__14 extends BaseMapper<SysOssConfig, SysOssConfigVo> {
}
