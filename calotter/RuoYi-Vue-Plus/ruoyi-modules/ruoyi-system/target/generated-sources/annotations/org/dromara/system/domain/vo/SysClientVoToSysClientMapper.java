package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__152;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysClient;
import org.dromara.system.domain.SysClientToSysClientVoMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__152.class,
    uses = {SysClientToSysClientVoMapper.class},
    imports = {}
)
public interface SysClientVoToSysClientMapper extends BaseMapper<SysClientVo, SysClient> {
}
