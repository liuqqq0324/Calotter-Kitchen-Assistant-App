package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__40;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysTenant;
import org.dromara.system.domain.SysTenantToSysTenantVoMapper__14;
import org.dromara.web.domain.vo.TenantListVoToSysTenantVoMapper__30;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__40.class,
    uses = {TenantListVoToSysTenantVoMapper__30.class,SysTenantVoToTenantListVoMapper__30.class,SysTenantToSysTenantVoMapper__14.class},
    imports = {}
)
public interface SysTenantVoToSysTenantMapper__14 extends BaseMapper<SysTenantVo, SysTenant> {
}
