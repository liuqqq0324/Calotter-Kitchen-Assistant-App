package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__137;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysTenant;
import org.dromara.system.domain.SysTenantToSysTenantVoMapper__1;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__137.class,
    uses = {SysTenantToSysTenantVoMapper__1.class},
    imports = {}
)
public interface SysTenantVoToSysTenantMapper__1 extends BaseMapper<SysTenantVo, SysTenant> {
}
