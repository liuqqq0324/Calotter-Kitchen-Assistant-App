package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__38;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysOssConfigBoToSysOssConfigMapper__4;
import org.dromara.system.domain.vo.SysOssConfigVo;
import org.dromara.system.domain.vo.SysOssConfigVoToSysOssConfigMapper__4;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__38.class,
    uses = {SysOssConfigVoToSysOssConfigMapper__4.class,SysOssConfigBoToSysOssConfigMapper__4.class},
    imports = {}
)
public interface SysOssConfigToSysOssConfigVoMapper__4 extends BaseMapper<SysOssConfig, SysOssConfigVo> {
}
