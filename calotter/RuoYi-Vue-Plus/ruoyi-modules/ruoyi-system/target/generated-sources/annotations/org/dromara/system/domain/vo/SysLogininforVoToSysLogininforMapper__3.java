package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__114;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysLogininfor;
import org.dromara.system.domain.SysLogininforToSysLogininforVoMapper__3;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__114.class,
    uses = {SysLogininforToSysLogininforVoMapper__3.class},
    imports = {}
)
public interface SysLogininforVoToSysLogininforMapper__3 extends BaseMapper<SysLogininforVo, SysLogininfor> {
}
