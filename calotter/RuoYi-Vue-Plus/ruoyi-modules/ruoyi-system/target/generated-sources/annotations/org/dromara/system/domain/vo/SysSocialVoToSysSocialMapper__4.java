package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__38;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysSocial;
import org.dromara.system.domain.SysSocialToSysSocialVoMapper__4;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__38.class,
    uses = {SysSocialToSysSocialVoMapper__4.class},
    imports = {}
)
public interface SysSocialVoToSysSocialMapper__4 extends BaseMapper<SysSocialVo, SysSocial> {
}
