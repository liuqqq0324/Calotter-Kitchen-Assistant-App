package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__12;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysClientBoToSysClientMapper;
import org.dromara.system.domain.vo.SysClientVo;
import org.dromara.system.domain.vo.SysClientVoToSysClientMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__12.class,
    uses = {SysClientVoToSysClientMapper.class,SysClientBoToSysClientMapper.class},
    imports = {}
)
public interface SysClientToSysClientVoMapper extends BaseMapper<SysClient, SysClientVo> {
}
