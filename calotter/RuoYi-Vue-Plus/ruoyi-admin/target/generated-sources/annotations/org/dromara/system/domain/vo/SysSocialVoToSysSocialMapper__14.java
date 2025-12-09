package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__40;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysSocial;
import org.dromara.system.domain.SysSocialToSysSocialVoMapper__14;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__40.class,
    uses = {SysSocialToSysSocialVoMapper__14.class},
    imports = {}
)
public interface SysSocialVoToSysSocialMapper__14 extends BaseMapper<SysSocialVo, SysSocial> {
}
