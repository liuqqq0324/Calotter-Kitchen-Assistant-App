package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__137;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysSocial;
import org.dromara.system.domain.SysSocialToSysSocialVoMapper__1;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__137.class,
    uses = {SysSocialToSysSocialVoMapper__1.class},
    imports = {}
)
public interface SysSocialVoToSysSocialMapper__1 extends BaseMapper<SysSocialVo, SysSocial> {
}
