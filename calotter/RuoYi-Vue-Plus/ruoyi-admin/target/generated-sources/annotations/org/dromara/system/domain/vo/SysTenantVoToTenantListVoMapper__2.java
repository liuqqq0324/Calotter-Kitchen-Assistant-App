package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__40;
import io.github.linpeilie.BaseMapper;
import org.dromara.web.domain.vo.TenantListVo;
import org.dromara.web.domain.vo.TenantListVoToSysTenantVoMapper__2;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__40.class,
    uses = {TenantListVoToSysTenantVoMapper__2.class},
    imports = {}
)
public interface SysTenantVoToTenantListVoMapper__2 extends BaseMapper<SysTenantVo, TenantListVo> {
}
