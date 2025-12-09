package org.dromara.system.domain.bo;

import io.github.linpeilie.AutoMapperConfig__40;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysTenant;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__40.class,
    uses = {},
    imports = {}
)
public interface SysTenantBoToSysTenantMapper__14 extends BaseMapper<SysTenantBo, SysTenant> {
}
