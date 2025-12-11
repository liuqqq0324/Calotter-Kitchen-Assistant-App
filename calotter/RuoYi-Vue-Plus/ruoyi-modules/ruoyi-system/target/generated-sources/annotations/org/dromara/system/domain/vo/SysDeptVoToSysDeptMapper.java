package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__152;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysDept;
import org.dromara.system.domain.SysDeptToSysDeptVoMapper;
import org.dromara.system.domain.bo.SysDeptBoToSysDeptMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__152.class,
    uses = {SysDeptBoToSysDeptMapper.class,SysDeptToSysDeptVoMapper.class,SysDeptToSysDeptVoMapper.class},
    imports = {}
)
public interface SysDeptVoToSysDeptMapper extends BaseMapper<SysDeptVo, SysDept> {
}
