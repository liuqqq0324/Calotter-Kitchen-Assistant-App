package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__38;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysLogininfor;
import org.dromara.system.domain.SysLogininforToSysLogininforVoMapper__4;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__38.class,
    uses = {SysLogininforToSysLogininforVoMapper__4.class},
    imports = {}
)
public interface SysLogininforVoToSysLogininforMapper__4 extends BaseMapper<SysLogininforVo, SysLogininfor> {
}
