package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__114;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysClient;
import org.dromara.system.domain.SysClientToSysClientVoMapper__3;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__114.class,
    uses = {SysClientToSysClientVoMapper__3.class},
    imports = {}
)
public interface SysClientVoToSysClientMapper__3 extends BaseMapper<SysClientVo, SysClient> {
}
