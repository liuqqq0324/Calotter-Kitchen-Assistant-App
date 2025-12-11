package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__137;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysLogininforBoToSysLogininforMapper__1;
import org.dromara.system.domain.vo.SysLogininforVo;
import org.dromara.system.domain.vo.SysLogininforVoToSysLogininforMapper__1;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__137.class,
    uses = {SysLogininforBoToSysLogininforMapper__1.class,SysLogininforVoToSysLogininforMapper__1.class},
    imports = {}
)
public interface SysLogininforToSysLogininforVoMapper__1 extends BaseMapper<SysLogininfor, SysLogininforVo> {
}
