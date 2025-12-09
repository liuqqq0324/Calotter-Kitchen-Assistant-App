package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__38;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysDeptBoToSysDeptMapper__4;
import org.dromara.system.domain.vo.SysDeptVo;
import org.dromara.system.domain.vo.SysDeptVoToSysDeptMapper__4;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__38.class,
    uses = {SysDeptBoToSysDeptMapper__4.class,SysDeptVoToSysDeptMapper__4.class,SysDeptBoToSysDeptMapper__4.class},
    imports = {}
)
public interface SysDeptToSysDeptVoMapper__4 extends BaseMapper<SysDept, SysDeptVo> {
}
