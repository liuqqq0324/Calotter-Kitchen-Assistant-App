package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__38;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysDictType;
import org.dromara.system.domain.SysDictTypeToSysDictTypeVoMapper__4;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__38.class,
    uses = {SysDictTypeToSysDictTypeVoMapper__4.class},
    imports = {}
)
public interface SysDictTypeVoToSysDictTypeMapper__4 extends BaseMapper<SysDictTypeVo, SysDictType> {
}
