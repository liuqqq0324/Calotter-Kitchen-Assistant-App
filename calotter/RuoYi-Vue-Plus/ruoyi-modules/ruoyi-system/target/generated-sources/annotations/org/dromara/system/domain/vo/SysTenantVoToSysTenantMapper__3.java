package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__114;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysTenant;
import org.dromara.system.domain.SysTenantToSysTenantVoMapper__3;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__114.class,
    uses = {SysTenantToSysTenantVoMapper__3.class},
    imports = {}
)
public interface SysTenantVoToSysTenantMapper__3 extends BaseMapper<SysTenantVo, SysTenant> {
}
