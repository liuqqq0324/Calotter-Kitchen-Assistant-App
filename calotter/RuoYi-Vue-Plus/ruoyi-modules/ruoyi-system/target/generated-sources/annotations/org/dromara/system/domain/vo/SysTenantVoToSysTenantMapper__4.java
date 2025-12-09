package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__38;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysTenant;
import org.dromara.system.domain.SysTenantToSysTenantVoMapper__4;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__38.class,
    uses = {SysTenantToSysTenantVoMapper__4.class},
    imports = {}
)
public interface SysTenantVoToSysTenantMapper__4 extends BaseMapper<SysTenantVo, SysTenant> {
}
