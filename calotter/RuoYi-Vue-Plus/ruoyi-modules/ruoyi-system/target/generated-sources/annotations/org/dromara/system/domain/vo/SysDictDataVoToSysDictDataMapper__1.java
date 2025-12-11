package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__137;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysDictData;
import org.dromara.system.domain.SysDictDataToSysDictDataVoMapper__1;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__137.class,
    uses = {SysDictDataToSysDictDataVoMapper__1.class},
    imports = {}
)
public interface SysDictDataVoToSysDictDataMapper__1 extends BaseMapper<SysDictDataVo, SysDictData> {
}
