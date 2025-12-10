package org.dromara.system.domain.bo;

import io.github.linpeilie.AutoMapperConfig__54;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysDictData;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__54.class,
    uses = {},
    imports = {}
)
public interface SysDictDataBoToSysDictDataMapper extends BaseMapper<SysDictDataBo, SysDictData> {
}
