package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__40;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysDept;
import org.dromara.system.domain.SysDeptToSysDeptVoMapper__14;
import org.dromara.system.domain.bo.SysDeptBoToSysDeptMapper__14;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__40.class,
    uses = {SysDeptBoToSysDeptMapper__14.class,SysDeptToSysDeptVoMapper__14.class,SysDeptToSysDeptVoMapper__14.class},
    imports = {}
)
public interface SysDeptVoToSysDeptMapper__14 extends BaseMapper<SysDeptVo, SysDept> {
}
