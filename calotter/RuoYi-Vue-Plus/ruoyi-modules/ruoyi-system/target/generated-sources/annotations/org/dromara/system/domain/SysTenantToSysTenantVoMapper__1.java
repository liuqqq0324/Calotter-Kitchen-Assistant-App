package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__137;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysTenantBoToSysTenantMapper__1;
import org.dromara.system.domain.vo.SysTenantVo;
import org.dromara.system.domain.vo.SysTenantVoToSysTenantMapper__1;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__137.class,
    uses = {SysTenantBoToSysTenantMapper__1.class,SysTenantVoToSysTenantMapper__1.class},
    imports = {}
)
public interface SysTenantToSysTenantVoMapper__1 extends BaseMapper<SysTenant, SysTenantVo> {
}
