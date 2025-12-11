package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__35;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysLogininfor;
import org.dromara.system.domain.SysLogininforToSysLogininforVoMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__35.class,
    uses = {SysLogininforToSysLogininforVoMapper.class},
    imports = {}
)
public interface SysLogininforVoToSysLogininforMapper extends BaseMapper<SysLogininforVo, SysLogininfor> {
}
