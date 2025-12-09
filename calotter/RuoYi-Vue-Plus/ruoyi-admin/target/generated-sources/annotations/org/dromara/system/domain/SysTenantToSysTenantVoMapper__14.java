package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__40;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysTenantBoToSysTenantMapper__14;
import org.dromara.system.domain.vo.SysTenantVo;
import org.dromara.system.domain.vo.SysTenantVoToSysTenantMapper__14;
import org.dromara.system.domain.vo.SysTenantVoToTenantListVoMapper__30;
import org.dromara.web.domain.vo.TenantListVoToSysTenantVoMapper__30;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__40.class,
    uses = {TenantListVoToSysTenantVoMapper__30.class,SysTenantVoToTenantListVoMapper__30.class,SysTenantBoToSysTenantMapper__14.class,SysTenantVoToSysTenantMapper__14.class},
    imports = {}
)
public interface SysTenantToSysTenantVoMapper__14 extends BaseMapper<SysTenant, SysTenantVo> {
}
