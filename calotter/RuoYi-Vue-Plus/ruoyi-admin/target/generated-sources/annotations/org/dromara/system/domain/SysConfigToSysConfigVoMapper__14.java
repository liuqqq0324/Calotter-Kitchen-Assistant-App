package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__40;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysConfigBoToSysConfigMapper__14;
import org.dromara.system.domain.vo.SysConfigVo;
import org.dromara.system.domain.vo.SysConfigVoToSysConfigMapper__14;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__40.class,
    uses = {SysConfigVoToSysConfigMapper__14.class,SysConfigBoToSysConfigMapper__14.class},
    imports = {}
)
public interface SysConfigToSysConfigVoMapper__14 extends BaseMapper<SysConfig, SysConfigVo> {
}
