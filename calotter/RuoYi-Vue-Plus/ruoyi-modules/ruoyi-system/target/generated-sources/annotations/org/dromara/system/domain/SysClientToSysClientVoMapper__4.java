package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__38;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysClientBoToSysClientMapper__4;
import org.dromara.system.domain.vo.SysClientVo;
import org.dromara.system.domain.vo.SysClientVoToSysClientMapper__4;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__38.class,
    uses = {SysClientVoToSysClientMapper__4.class,SysClientBoToSysClientMapper__4.class},
    imports = {}
)
public interface SysClientToSysClientVoMapper__4 extends BaseMapper<SysClient, SysClientVo> {
}
