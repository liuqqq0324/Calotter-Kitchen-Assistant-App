package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__114;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysClientBoToSysClientMapper__3;
import org.dromara.system.domain.vo.SysClientVo;
import org.dromara.system.domain.vo.SysClientVoToSysClientMapper__3;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__114.class,
    uses = {SysClientVoToSysClientMapper__3.class,SysClientBoToSysClientMapper__3.class},
    imports = {}
)
public interface SysClientToSysClientVoMapper__3 extends BaseMapper<SysClient, SysClientVo> {
}
