package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__152;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysLogininforBoToSysLogininforMapper;
import org.dromara.system.domain.vo.SysLogininforVo;
import org.dromara.system.domain.vo.SysLogininforVoToSysLogininforMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__152.class,
    uses = {SysLogininforBoToSysLogininforMapper.class,SysLogininforVoToSysLogininforMapper.class},
    imports = {}
)
public interface SysLogininforToSysLogininforVoMapper extends BaseMapper<SysLogininfor, SysLogininforVo> {
}
