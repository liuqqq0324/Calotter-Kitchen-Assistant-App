package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__40;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysDictDataBoToSysDictDataMapper__14;
import org.dromara.system.domain.vo.SysDictDataVo;
import org.dromara.system.domain.vo.SysDictDataVoToSysDictDataMapper__14;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__40.class,
    uses = {SysDictDataBoToSysDictDataMapper__14.class,SysDictDataVoToSysDictDataMapper__14.class},
    imports = {}
)
public interface SysDictDataToSysDictDataVoMapper__14 extends BaseMapper<SysDictData, SysDictDataVo> {
}
