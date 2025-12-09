package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__38;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysTenantPackage;
import org.dromara.system.domain.SysTenantPackageToSysTenantPackageVoMapper__4;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__38.class,
    uses = {SysTenantPackageToSysTenantPackageVoMapper__4.class},
    imports = {}
)
public interface SysTenantPackageVoToSysTenantPackageMapper__4 extends BaseMapper<SysTenantPackageVo, SysTenantPackage> {
}
