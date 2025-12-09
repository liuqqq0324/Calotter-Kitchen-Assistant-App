package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__40;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysDeptBoToSysDeptMapper__14;
import org.dromara.system.domain.vo.SysDeptVo;
import org.dromara.system.domain.vo.SysDeptVoToSysDeptMapper__14;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__40.class,
    uses = {SysDeptBoToSysDeptMapper__14.class,SysDeptVoToSysDeptMapper__14.class,SysDeptBoToSysDeptMapper__14.class},
    imports = {}
)
public interface SysDeptToSysDeptVoMapper__14 extends BaseMapper<SysDept, SysDeptVo> {
}
