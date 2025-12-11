package org.dromara.system.domain.bo;

import io.github.linpeilie.AutoMapperConfig__114;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysConfig;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__114.class,
    uses = {},
    imports = {}
)
public interface SysConfigBoToSysConfigMapper__3 extends BaseMapper<SysConfigBo, SysConfig> {
}
