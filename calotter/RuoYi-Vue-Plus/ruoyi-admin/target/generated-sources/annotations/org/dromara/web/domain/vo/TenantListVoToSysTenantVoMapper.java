package org.dromara.web.domain.vo;

import io.github.linpeilie.AutoMapperConfig__38;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.vo.SysTenantVo;
import org.dromara.system.domain.vo.SysTenantVoToTenantListVoMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__38.class,
    uses = {SysTenantVoToTenantListVoMapper.class},
    imports = {}
)
public interface TenantListVoToSysTenantVoMapper extends BaseMapper<TenantListVo, SysTenantVo> {
}
