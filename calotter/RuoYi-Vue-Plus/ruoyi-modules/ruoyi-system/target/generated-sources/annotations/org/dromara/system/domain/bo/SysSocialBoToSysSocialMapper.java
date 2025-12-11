package org.dromara.system.domain.bo;

import io.github.linpeilie.AutoMapperConfig__152;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysSocial;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__152.class,
    uses = {},
    imports = {}
)
public interface SysSocialBoToSysSocialMapper extends BaseMapper<SysSocialBo, SysSocial> {
}
