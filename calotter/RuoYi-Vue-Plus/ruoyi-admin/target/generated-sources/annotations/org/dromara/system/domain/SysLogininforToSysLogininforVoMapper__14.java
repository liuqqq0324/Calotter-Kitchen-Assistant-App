package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__40;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysLogininforBoToSysLogininforMapper__14;
import org.dromara.system.domain.vo.SysLogininforVo;
import org.dromara.system.domain.vo.SysLogininforVoToSysLogininforMapper__14;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__40.class,
    uses = {SysLogininforBoToSysLogininforMapper__14.class,SysLogininforVoToSysLogininforMapper__14.class},
    imports = {}
)
public interface SysLogininforToSysLogininforVoMapper__14 extends BaseMapper<SysLogininfor, SysLogininforVo> {
}
