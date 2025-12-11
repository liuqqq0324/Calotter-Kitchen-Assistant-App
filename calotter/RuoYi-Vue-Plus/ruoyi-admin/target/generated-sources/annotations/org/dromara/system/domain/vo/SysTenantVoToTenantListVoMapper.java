package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__140;
import io.github.linpeilie.BaseMapper;
import org.dromara.web.domain.vo.TenantListVo;
import org.dromara.web.domain.vo.TenantListVoToSysTenantVoMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__140.class,
    uses = {TenantListVoToSysTenantVoMapper.class},
    imports = {}
)
public interface SysTenantVoToTenantListVoMapper extends BaseMapper<SysTenantVo, TenantListVo> {
}
