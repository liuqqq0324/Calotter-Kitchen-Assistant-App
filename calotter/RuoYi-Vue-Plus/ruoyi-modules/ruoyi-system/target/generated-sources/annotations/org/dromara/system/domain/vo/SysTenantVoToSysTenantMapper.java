package org.dromara.system.domain.vo;

<<<<<<< HEAD
import io.github.linpeilie.AutoMapperConfig__54;
=======
import io.github.linpeilie.AutoMapperConfig__12;
>>>>>>> chase/flutter-v1-android-java
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysTenant;
import org.dromara.system.domain.SysTenantToSysTenantVoMapper;
import org.mapstruct.Mapper;

@Mapper(
<<<<<<< HEAD
    config = AutoMapperConfig__54.class,
=======
    config = AutoMapperConfig__12.class,
>>>>>>> chase/flutter-v1-android-java
    uses = {SysTenantToSysTenantVoMapper.class},
    imports = {}
)
public interface SysTenantVoToSysTenantMapper extends BaseMapper<SysTenantVo, SysTenant> {
}
