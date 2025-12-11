package org.dromara.system.domain.bo;

<<<<<<< HEAD
import io.github.linpeilie.AutoMapperConfig__54;
=======
import io.github.linpeilie.AutoMapperConfig__12;
>>>>>>> chase/flutter-v1-android-java
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysTenantPackage;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;

@Mapper(
<<<<<<< HEAD
    config = AutoMapperConfig__54.class,
=======
    config = AutoMapperConfig__12.class,
>>>>>>> chase/flutter-v1-android-java
    uses = {},
    imports = {}
)
public interface SysTenantPackageBoToSysTenantPackageMapper extends BaseMapper<SysTenantPackageBo, SysTenantPackage> {
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
