package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__40;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysTenantPackage;
import org.dromara.system.domain.SysTenantPackageToSysTenantPackageVoMapper__14;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__40.class,
    uses = {SysTenantPackageToSysTenantPackageVoMapper__14.class},
    imports = {}
)
public interface SysTenantPackageVoToSysTenantPackageMapper__14 extends BaseMapper<SysTenantPackageVo, SysTenantPackage> {
}
