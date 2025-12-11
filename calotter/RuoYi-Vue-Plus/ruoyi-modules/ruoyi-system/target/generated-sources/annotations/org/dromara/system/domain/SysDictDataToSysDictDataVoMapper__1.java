package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__137;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysDictDataBoToSysDictDataMapper__1;
import org.dromara.system.domain.vo.SysDictDataVo;
import org.dromara.system.domain.vo.SysDictDataVoToSysDictDataMapper__1;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__137.class,
    uses = {SysDictDataBoToSysDictDataMapper__1.class,SysDictDataVoToSysDictDataMapper__1.class},
    imports = {}
)
public interface SysDictDataToSysDictDataVoMapper__1 extends BaseMapper<SysDictData, SysDictDataVo> {
}
