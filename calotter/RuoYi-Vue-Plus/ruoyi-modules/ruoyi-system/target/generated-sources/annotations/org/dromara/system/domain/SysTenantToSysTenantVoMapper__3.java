package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__114;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysTenantBoToSysTenantMapper__3;
import org.dromara.system.domain.vo.SysTenantVo;
import org.dromara.system.domain.vo.SysTenantVoToSysTenantMapper__3;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__114.class,
    uses = {SysTenantBoToSysTenantMapper__3.class,SysTenantVoToSysTenantMapper__3.class},
    imports = {}
)
public interface SysTenantToSysTenantVoMapper__3 extends BaseMapper<SysTenant, SysTenantVo> {
}
