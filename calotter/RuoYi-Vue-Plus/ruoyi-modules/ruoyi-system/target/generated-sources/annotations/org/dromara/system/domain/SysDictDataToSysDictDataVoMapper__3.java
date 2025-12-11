package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__114;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysDictDataBoToSysDictDataMapper__3;
import org.dromara.system.domain.vo.SysDictDataVo;
import org.dromara.system.domain.vo.SysDictDataVoToSysDictDataMapper__3;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__114.class,
    uses = {SysDictDataBoToSysDictDataMapper__3.class,SysDictDataVoToSysDictDataMapper__3.class},
    imports = {}
)
public interface SysDictDataToSysDictDataVoMapper__3 extends BaseMapper<SysDictData, SysDictDataVo> {
}
