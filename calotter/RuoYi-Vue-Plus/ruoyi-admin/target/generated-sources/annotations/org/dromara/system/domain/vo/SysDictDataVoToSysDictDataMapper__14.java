package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__40;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysDictData;
import org.dromara.system.domain.SysDictDataToSysDictDataVoMapper__14;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__40.class,
    uses = {SysDictDataToSysDictDataVoMapper__14.class},
    imports = {}
)
public interface SysDictDataVoToSysDictDataMapper__14 extends BaseMapper<SysDictDataVo, SysDictData> {
}
