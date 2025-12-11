package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__114;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysTenantPackage;
import org.dromara.system.domain.SysTenantPackageToSysTenantPackageVoMapper__3;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__114.class,
    uses = {SysTenantPackageToSysTenantPackageVoMapper__3.class},
    imports = {}
)
public interface SysTenantPackageVoToSysTenantPackageMapper__3 extends BaseMapper<SysTenantPackageVo, SysTenantPackage> {
}
