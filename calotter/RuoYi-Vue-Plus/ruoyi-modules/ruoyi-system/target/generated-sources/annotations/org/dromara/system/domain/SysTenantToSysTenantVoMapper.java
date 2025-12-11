package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__152;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysTenantBoToSysTenantMapper;
import org.dromara.system.domain.vo.SysTenantVo;
import org.dromara.system.domain.vo.SysTenantVoToSysTenantMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__152.class,
    uses = {SysTenantBoToSysTenantMapper.class,SysTenantVoToSysTenantMapper.class},
    imports = {}
)
public interface SysTenantToSysTenantVoMapper extends BaseMapper<SysTenant, SysTenantVo> {
}
