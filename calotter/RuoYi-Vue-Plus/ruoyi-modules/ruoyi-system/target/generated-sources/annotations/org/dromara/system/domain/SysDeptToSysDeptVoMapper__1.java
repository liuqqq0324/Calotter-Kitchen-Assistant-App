package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__137;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysDeptBoToSysDeptMapper__1;
import org.dromara.system.domain.vo.SysDeptVo;
import org.dromara.system.domain.vo.SysDeptVoToSysDeptMapper__1;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__137.class,
    uses = {SysDeptBoToSysDeptMapper__1.class,SysDeptVoToSysDeptMapper__1.class,SysDeptBoToSysDeptMapper__1.class},
    imports = {}
)
public interface SysDeptToSysDeptVoMapper__1 extends BaseMapper<SysDept, SysDeptVo> {
}
