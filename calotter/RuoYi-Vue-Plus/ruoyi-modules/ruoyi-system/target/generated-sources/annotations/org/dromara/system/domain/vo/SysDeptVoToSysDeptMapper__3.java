package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__114;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysDept;
import org.dromara.system.domain.SysDeptToSysDeptVoMapper__3;
import org.dromara.system.domain.bo.SysDeptBoToSysDeptMapper__3;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__114.class,
    uses = {SysDeptBoToSysDeptMapper__3.class,SysDeptToSysDeptVoMapper__3.class,SysDeptToSysDeptVoMapper__3.class},
    imports = {}
)
public interface SysDeptVoToSysDeptMapper__3 extends BaseMapper<SysDeptVo, SysDept> {
}
