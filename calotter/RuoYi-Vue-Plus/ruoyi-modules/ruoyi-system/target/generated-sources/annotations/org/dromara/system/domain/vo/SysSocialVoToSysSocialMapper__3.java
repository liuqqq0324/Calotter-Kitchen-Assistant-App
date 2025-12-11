package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__114;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysSocial;
import org.dromara.system.domain.SysSocialToSysSocialVoMapper__3;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__114.class,
    uses = {SysSocialToSysSocialVoMapper__3.class},
    imports = {}
)
public interface SysSocialVoToSysSocialMapper__3 extends BaseMapper<SysSocialVo, SysSocial> {
}
