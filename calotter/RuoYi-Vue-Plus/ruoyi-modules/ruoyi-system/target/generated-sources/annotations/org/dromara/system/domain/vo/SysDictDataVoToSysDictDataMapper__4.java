package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__38;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysDictData;
import org.dromara.system.domain.SysDictDataToSysDictDataVoMapper__4;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__38.class,
    uses = {SysDictDataToSysDictDataVoMapper__4.class},
    imports = {}
)
public interface SysDictDataVoToSysDictDataMapper__4 extends BaseMapper<SysDictDataVo, SysDictData> {
}
