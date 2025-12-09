package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__40;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysDictTypeBoToSysDictTypeMapper__14;
import org.dromara.system.domain.vo.SysDictTypeVo;
import org.dromara.system.domain.vo.SysDictTypeVoToSysDictTypeMapper__14;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__40.class,
    uses = {SysDictTypeBoToSysDictTypeMapper__14.class,SysDictTypeVoToSysDictTypeMapper__14.class},
    imports = {}
)
public interface SysDictTypeToSysDictTypeVoMapper__14 extends BaseMapper<SysDictType, SysDictTypeVo> {
}
