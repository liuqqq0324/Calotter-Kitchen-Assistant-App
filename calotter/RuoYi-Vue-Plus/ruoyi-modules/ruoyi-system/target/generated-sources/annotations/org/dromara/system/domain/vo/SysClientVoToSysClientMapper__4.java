package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__38;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysClient;
import org.dromara.system.domain.SysClientToSysClientVoMapper__4;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__38.class,
    uses = {SysClientToSysClientVoMapper__4.class},
    imports = {}
)
public interface SysClientVoToSysClientMapper__4 extends BaseMapper<SysClientVo, SysClient> {
}
