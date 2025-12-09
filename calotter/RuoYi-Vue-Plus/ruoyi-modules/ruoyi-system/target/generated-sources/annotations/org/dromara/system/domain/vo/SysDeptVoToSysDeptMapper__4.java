package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__38;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysDept;
import org.dromara.system.domain.SysDeptToSysDeptVoMapper__4;
import org.dromara.system.domain.bo.SysDeptBoToSysDeptMapper__4;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__38.class,
    uses = {SysDeptBoToSysDeptMapper__4.class,SysDeptToSysDeptVoMapper__4.class,SysDeptToSysDeptVoMapper__4.class},
    imports = {}
)
public interface SysDeptVoToSysDeptMapper__4 extends BaseMapper<SysDeptVo, SysDept> {
}
