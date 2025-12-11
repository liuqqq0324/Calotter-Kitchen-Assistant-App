package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__114;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysOssConfigBoToSysOssConfigMapper__3;
import org.dromara.system.domain.vo.SysOssConfigVo;
import org.dromara.system.domain.vo.SysOssConfigVoToSysOssConfigMapper__3;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__114.class,
    uses = {SysOssConfigVoToSysOssConfigMapper__3.class,SysOssConfigBoToSysOssConfigMapper__3.class},
    imports = {}
)
public interface SysOssConfigToSysOssConfigVoMapper__3 extends BaseMapper<SysOssConfig, SysOssConfigVo> {
}
