package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__114;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysDictData;
import org.dromara.system.domain.SysDictDataToSysDictDataVoMapper__3;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__114.class,
    uses = {SysDictDataToSysDictDataVoMapper__3.class},
    imports = {}
)
public interface SysDictDataVoToSysDictDataMapper__3 extends BaseMapper<SysDictDataVo, SysDictData> {
}
