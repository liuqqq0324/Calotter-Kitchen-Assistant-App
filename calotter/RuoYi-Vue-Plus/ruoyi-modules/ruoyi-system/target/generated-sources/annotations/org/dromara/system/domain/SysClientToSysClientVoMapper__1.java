package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__137;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysClientBoToSysClientMapper__1;
import org.dromara.system.domain.vo.SysClientVo;
import org.dromara.system.domain.vo.SysClientVoToSysClientMapper__1;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__137.class,
    uses = {SysClientVoToSysClientMapper__1.class,SysClientBoToSysClientMapper__1.class},
    imports = {}
)
public interface SysClientToSysClientVoMapper__1 extends BaseMapper<SysClient, SysClientVo> {
}
