package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__40;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysClient;
import org.dromara.system.domain.SysClientToSysClientVoMapper__14;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__40.class,
    uses = {SysClientToSysClientVoMapper__14.class},
    imports = {}
)
public interface SysClientVoToSysClientMapper__14 extends BaseMapper<SysClientVo, SysClient> {
}
