package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__114;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysDictTypeBoToSysDictTypeMapper__3;
import org.dromara.system.domain.vo.SysDictTypeVo;
import org.dromara.system.domain.vo.SysDictTypeVoToSysDictTypeMapper__3;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__114.class,
    uses = {SysDictTypeBoToSysDictTypeMapper__3.class,SysDictTypeVoToSysDictTypeMapper__3.class},
    imports = {}
)
public interface SysDictTypeToSysDictTypeVoMapper__3 extends BaseMapper<SysDictType, SysDictTypeVo> {
}
