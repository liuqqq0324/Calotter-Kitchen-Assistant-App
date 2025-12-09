package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__40;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysClientBoToSysClientMapper__14;
import org.dromara.system.domain.vo.SysClientVo;
import org.dromara.system.domain.vo.SysClientVoToSysClientMapper__14;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__40.class,
    uses = {SysClientVoToSysClientMapper__14.class,SysClientBoToSysClientMapper__14.class},
    imports = {}
)
public interface SysClientToSysClientVoMapper__14 extends BaseMapper<SysClient, SysClientVo> {
}
