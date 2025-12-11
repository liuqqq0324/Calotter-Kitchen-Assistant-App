package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__114;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysLogininforBoToSysLogininforMapper__3;
import org.dromara.system.domain.vo.SysLogininforVo;
import org.dromara.system.domain.vo.SysLogininforVoToSysLogininforMapper__3;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__114.class,
    uses = {SysLogininforBoToSysLogininforMapper__3.class,SysLogininforVoToSysLogininforMapper__3.class},
    imports = {}
)
public interface SysLogininforToSysLogininforVoMapper__3 extends BaseMapper<SysLogininfor, SysLogininforVo> {
}
