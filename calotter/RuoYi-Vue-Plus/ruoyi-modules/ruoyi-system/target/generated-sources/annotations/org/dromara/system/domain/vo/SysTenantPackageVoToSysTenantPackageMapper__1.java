package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__137;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysTenantPackage;
import org.dromara.system.domain.SysTenantPackageToSysTenantPackageVoMapper__1;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__137.class,
    uses = {SysTenantPackageToSysTenantPackageVoMapper__1.class},
    imports = {}
)
public interface SysTenantPackageVoToSysTenantPackageMapper__1 extends BaseMapper<SysTenantPackageVo, SysTenantPackage> {
}
