package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__137;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysDictType;
import org.dromara.system.domain.SysDictTypeToSysDictTypeVoMapper__1;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__137.class,
    uses = {SysDictTypeToSysDictTypeVoMapper__1.class},
    imports = {}
)
public interface SysDictTypeVoToSysDictTypeMapper__1 extends BaseMapper<SysDictTypeVo, SysDictType> {
}
