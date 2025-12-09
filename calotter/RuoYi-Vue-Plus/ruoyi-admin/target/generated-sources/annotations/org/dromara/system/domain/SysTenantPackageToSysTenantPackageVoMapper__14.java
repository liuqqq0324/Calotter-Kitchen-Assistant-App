package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__40;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysTenantPackageBoToSysTenantPackageMapper__14;
import org.dromara.system.domain.vo.SysTenantPackageVo;
import org.dromara.system.domain.vo.SysTenantPackageVoToSysTenantPackageMapper__14;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__40.class,
    uses = {SysTenantPackageBoToSysTenantPackageMapper__14.class,SysTenantPackageVoToSysTenantPackageMapper__14.class},
    imports = {}
)
public interface SysTenantPackageToSysTenantPackageVoMapper__14 extends BaseMapper<SysTenantPackage, SysTenantPackageVo> {
}
