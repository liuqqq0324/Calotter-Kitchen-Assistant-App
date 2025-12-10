package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__12;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysDictType;
import org.dromara.system.domain.SysDictTypeToSysDictTypeVoMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__12.class,
    uses = {SysDictTypeToSysDictTypeVoMapper.class},
    imports = {}
)
public interface SysDictTypeVoToSysDictTypeMapper extends BaseMapper<SysDictTypeVo, SysDictType> {
}
