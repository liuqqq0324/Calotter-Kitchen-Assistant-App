package org.dromara.system.domain.bo;

import io.github.linpeilie.AutoMapperConfig__38;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysTenantPackage;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;

@Mapper(
    config = AutoMapperConfig__38.class,
    uses = {},
    imports = {}
)
public interface SysTenantPackageBoToSysTenantPackageMapper__4 extends BaseMapper<SysTenantPackageBo, SysTenantPackage> {
  @Mapping(
      target = "menuIds",
      expression = "java(org.dromara.common.core.utils.StringUtils.joinComma(source.getMenuIds()))"
  )
  SysTenantPackage convert(SysTenantPackageBo source);

  @Mapping(
      target = "menuIds",
      expression = "java(org.dromara.common.core.utils.StringUtils.joinComma(source.getMenuIds()))"
  )
  SysTenantPackage convert(SysTenantPackageBo source, @MappingTarget SysTenantPackage target);
}
