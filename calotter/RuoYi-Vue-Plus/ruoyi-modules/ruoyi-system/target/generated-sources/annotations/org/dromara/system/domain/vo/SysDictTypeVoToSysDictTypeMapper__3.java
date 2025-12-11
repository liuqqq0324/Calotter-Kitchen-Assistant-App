package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__114;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysDictType;
import org.dromara.system.domain.SysDictTypeToSysDictTypeVoMapper__3;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__114.class,
    uses = {SysDictTypeToSysDictTypeVoMapper__3.class},
    imports = {}
)
public interface SysDictTypeVoToSysDictTypeMapper__3 extends BaseMapper<SysDictTypeVo, SysDictType> {
}
