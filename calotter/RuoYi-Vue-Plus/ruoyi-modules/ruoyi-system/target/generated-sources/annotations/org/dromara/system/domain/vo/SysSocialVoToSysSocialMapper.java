package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__152;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysSocial;
import org.dromara.system.domain.SysSocialToSysSocialVoMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__152.class,
    uses = {SysSocialToSysSocialVoMapper.class},
    imports = {}
)
public interface SysSocialVoToSysSocialMapper extends BaseMapper<SysSocialVo, SysSocial> {
}
