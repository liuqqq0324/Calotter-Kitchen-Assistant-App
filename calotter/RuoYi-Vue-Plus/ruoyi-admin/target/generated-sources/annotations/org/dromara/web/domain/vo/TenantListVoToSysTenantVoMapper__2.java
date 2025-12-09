package org.dromara.web.domain.vo;

import io.github.linpeilie.AutoMapperConfig__40;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.vo.SysTenantVo;
import org.dromara.system.domain.vo.SysTenantVoToTenantListVoMapper__2;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__40.class,
    uses = {SysTenantVoToTenantListVoMapper__2.class},
    imports = {}
)
public interface TenantListVoToSysTenantVoMapper__2 extends BaseMapper<TenantListVo, SysTenantVo> {
}
