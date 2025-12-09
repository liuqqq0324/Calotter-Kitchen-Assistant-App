package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__38;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysDictDataBoToSysDictDataMapper__4;
import org.dromara.system.domain.vo.SysDictDataVo;
import org.dromara.system.domain.vo.SysDictDataVoToSysDictDataMapper__4;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__38.class,
    uses = {SysDictDataBoToSysDictDataMapper__4.class,SysDictDataVoToSysDictDataMapper__4.class},
    imports = {}
)
public interface SysDictDataToSysDictDataVoMapper__4 extends BaseMapper<SysDictData, SysDictDataVo> {
}
