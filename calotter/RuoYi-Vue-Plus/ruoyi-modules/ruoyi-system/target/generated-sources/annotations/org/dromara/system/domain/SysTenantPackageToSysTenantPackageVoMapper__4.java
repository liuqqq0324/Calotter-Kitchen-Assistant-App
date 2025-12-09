package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__38;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysTenantPackageBoToSysTenantPackageMapper__4;
import org.dromara.system.domain.vo.SysTenantPackageVo;
import org.dromara.system.domain.vo.SysTenantPackageVoToSysTenantPackageMapper__4;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__38.class,
    uses = {SysTenantPackageBoToSysTenantPackageMapper__4.class,SysTenantPackageVoToSysTenantPackageMapper__4.class},
    imports = {}
)
public interface SysTenantPackageToSysTenantPackageVoMapper__4 extends BaseMapper<SysTenantPackage, SysTenantPackageVo> {
}
