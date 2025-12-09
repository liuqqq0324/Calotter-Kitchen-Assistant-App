package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__38;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysDictTypeBoToSysDictTypeMapper__4;
import org.dromara.system.domain.vo.SysDictTypeVo;
import org.dromara.system.domain.vo.SysDictTypeVoToSysDictTypeMapper__4;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__38.class,
    uses = {SysDictTypeBoToSysDictTypeMapper__4.class,SysDictTypeVoToSysDictTypeMapper__4.class},
    imports = {}
)
public interface SysDictTypeToSysDictTypeVoMapper__4 extends BaseMapper<SysDictType, SysDictTypeVo> {
}
