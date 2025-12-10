package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__12;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysConfig;
import org.dromara.system.domain.SysConfigToSysConfigVoMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__12.class,
    uses = {SysConfigToSysConfigVoMapper.class},
    imports = {}
)
public interface SysConfigVoToSysConfigMapper extends BaseMapper<SysConfigVo, SysConfig> {
}
