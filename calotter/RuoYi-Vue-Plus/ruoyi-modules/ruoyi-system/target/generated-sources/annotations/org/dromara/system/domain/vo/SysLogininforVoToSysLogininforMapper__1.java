package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__137;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysLogininfor;
import org.dromara.system.domain.SysLogininforToSysLogininforVoMapper__1;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__137.class,
    uses = {SysLogininforToSysLogininforVoMapper__1.class},
    imports = {}
)
public interface SysLogininforVoToSysLogininforMapper__1 extends BaseMapper<SysLogininforVo, SysLogininfor> {
}
