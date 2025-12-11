package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__114;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysTenantPackageBoToSysTenantPackageMapper__3;
import org.dromara.system.domain.vo.SysTenantPackageVo;
import org.dromara.system.domain.vo.SysTenantPackageVoToSysTenantPackageMapper__3;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__114.class,
    uses = {SysTenantPackageBoToSysTenantPackageMapper__3.class,SysTenantPackageVoToSysTenantPackageMapper__3.class},
    imports = {}
)
public interface SysTenantPackageToSysTenantPackageVoMapper__3 extends BaseMapper<SysTenantPackage, SysTenantPackageVo> {
}
