package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__38;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysLogininforBoToSysLogininforMapper__4;
import org.dromara.system.domain.vo.SysLogininforVo;
import org.dromara.system.domain.vo.SysLogininforVoToSysLogininforMapper__4;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__38.class,
    uses = {SysLogininforBoToSysLogininforMapper__4.class,SysLogininforVoToSysLogininforMapper__4.class},
    imports = {}
)
public interface SysLogininforToSysLogininforVoMapper__4 extends BaseMapper<SysLogininfor, SysLogininforVo> {
}
