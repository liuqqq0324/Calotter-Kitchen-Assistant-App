package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__114;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysConfigBoToSysConfigMapper__3;
import org.dromara.system.domain.vo.SysConfigVo;
import org.dromara.system.domain.vo.SysConfigVoToSysConfigMapper__3;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__114.class,
    uses = {SysConfigVoToSysConfigMapper__3.class,SysConfigBoToSysConfigMapper__3.class},
    imports = {}
)
public interface SysConfigToSysConfigVoMapper__3 extends BaseMapper<SysConfig, SysConfigVo> {
}
