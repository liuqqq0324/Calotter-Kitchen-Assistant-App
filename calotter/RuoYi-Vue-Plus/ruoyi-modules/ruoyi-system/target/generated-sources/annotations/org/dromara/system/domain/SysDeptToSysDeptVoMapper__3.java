package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__114;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysDeptBoToSysDeptMapper__3;
import org.dromara.system.domain.vo.SysDeptVo;
import org.dromara.system.domain.vo.SysDeptVoToSysDeptMapper__3;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__114.class,
    uses = {SysDeptBoToSysDeptMapper__3.class,SysDeptVoToSysDeptMapper__3.class,SysDeptBoToSysDeptMapper__3.class},
    imports = {}
)
public interface SysDeptToSysDeptVoMapper__3 extends BaseMapper<SysDept, SysDeptVo> {
}
