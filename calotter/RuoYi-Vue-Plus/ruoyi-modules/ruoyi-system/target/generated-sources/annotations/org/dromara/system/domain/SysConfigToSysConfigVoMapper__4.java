package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__38;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysConfigBoToSysConfigMapper__4;
import org.dromara.system.domain.vo.SysConfigVo;
import org.dromara.system.domain.vo.SysConfigVoToSysConfigMapper__4;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__38.class,
    uses = {SysConfigVoToSysConfigMapper__4.class,SysConfigBoToSysConfigMapper__4.class},
    imports = {}
)
public interface SysConfigToSysConfigVoMapper__4 extends BaseMapper<SysConfig, SysConfigVo> {
}
