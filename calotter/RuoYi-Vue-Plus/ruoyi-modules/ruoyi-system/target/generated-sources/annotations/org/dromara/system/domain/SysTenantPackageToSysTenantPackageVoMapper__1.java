package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__137;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysTenantPackageBoToSysTenantPackageMapper__1;
import org.dromara.system.domain.vo.SysTenantPackageVo;
import org.dromara.system.domain.vo.SysTenantPackageVoToSysTenantPackageMapper__1;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__137.class,
    uses = {SysTenantPackageBoToSysTenantPackageMapper__1.class,SysTenantPackageVoToSysTenantPackageMapper__1.class},
    imports = {}
)
public interface SysTenantPackageToSysTenantPackageVoMapper__1 extends BaseMapper<SysTenantPackage, SysTenantPackageVo> {
}
