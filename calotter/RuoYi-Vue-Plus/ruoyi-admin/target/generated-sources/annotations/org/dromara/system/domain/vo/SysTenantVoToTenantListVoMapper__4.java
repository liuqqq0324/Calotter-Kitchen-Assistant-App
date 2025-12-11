package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__117;
import io.github.linpeilie.BaseMapper;
import org.dromara.web.domain.vo.TenantListVo;
import org.dromara.web.domain.vo.TenantListVoToSysTenantVoMapper__4;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__117.class,
    uses = {TenantListVoToSysTenantVoMapper__4.class},
    imports = {}
)
public interface SysTenantVoToTenantListVoMapper__4 extends BaseMapper<SysTenantVo, TenantListVo> {
}
