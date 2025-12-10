package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__54;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysTenantPackageBoToSysTenantPackageMapper;
import org.dromara.system.domain.vo.SysTenantPackageVo;
import org.dromara.system.domain.vo.SysTenantPackageVoToSysTenantPackageMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__54.class,
    uses = {SysTenantPackageBoToSysTenantPackageMapper.class,SysTenantPackageVoToSysTenantPackageMapper.class},
    imports = {}
)
public interface SysTenantPackageToSysTenantPackageVoMapper extends BaseMapper<SysTenantPackage, SysTenantPackageVo> {
}
