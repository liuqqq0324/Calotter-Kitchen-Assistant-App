package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__40;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysDictType;
import org.dromara.system.domain.SysDictTypeToSysDictTypeVoMapper__14;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__40.class,
    uses = {SysDictTypeToSysDictTypeVoMapper__14.class},
    imports = {}
)
public interface SysDictTypeVoToSysDictTypeMapper__14 extends BaseMapper<SysDictTypeVo, SysDictType> {
}
