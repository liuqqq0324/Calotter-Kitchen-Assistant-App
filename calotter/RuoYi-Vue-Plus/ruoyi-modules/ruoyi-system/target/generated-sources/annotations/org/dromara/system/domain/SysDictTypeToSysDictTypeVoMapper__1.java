package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__137;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysDictTypeBoToSysDictTypeMapper__1;
import org.dromara.system.domain.vo.SysDictTypeVo;
import org.dromara.system.domain.vo.SysDictTypeVoToSysDictTypeMapper__1;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__137.class,
    uses = {SysDictTypeBoToSysDictTypeMapper__1.class,SysDictTypeVoToSysDictTypeMapper__1.class},
    imports = {}
)
public interface SysDictTypeToSysDictTypeVoMapper__1 extends BaseMapper<SysDictType, SysDictTypeVo> {
}
