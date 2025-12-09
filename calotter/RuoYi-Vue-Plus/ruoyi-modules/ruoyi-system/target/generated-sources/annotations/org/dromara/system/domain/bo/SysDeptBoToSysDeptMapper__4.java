package org.dromara.system.domain.bo;

import io.github.linpeilie.AutoMapperConfig__38;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysDept;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__38.class,
    uses = {},
    imports = {}
)
public interface SysDeptBoToSysDeptMapper__4 extends BaseMapper<SysDeptBo, SysDept> {
}
