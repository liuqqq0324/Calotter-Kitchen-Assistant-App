package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__137;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysDept;
import org.dromara.system.domain.SysDeptToSysDeptVoMapper__1;
import org.dromara.system.domain.bo.SysDeptBoToSysDeptMapper__1;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__137.class,
    uses = {SysDeptBoToSysDeptMapper__1.class,SysDeptToSysDeptVoMapper__1.class,SysDeptToSysDeptVoMapper__1.class},
    imports = {}
)
public interface SysDeptVoToSysDeptMapper__1 extends BaseMapper<SysDeptVo, SysDept> {
}
