package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__137;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysClient;
import org.dromara.system.domain.SysClientToSysClientVoMapper__1;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__137.class,
    uses = {SysClientToSysClientVoMapper__1.class},
    imports = {}
)
public interface SysClientVoToSysClientMapper__1 extends BaseMapper<SysClientVo, SysClient> {
}
