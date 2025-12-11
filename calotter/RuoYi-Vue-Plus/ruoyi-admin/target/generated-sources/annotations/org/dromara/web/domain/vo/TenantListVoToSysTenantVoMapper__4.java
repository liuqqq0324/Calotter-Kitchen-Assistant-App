package org.dromara.web.domain.vo;

import io.github.linpeilie.AutoMapperConfig__117;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.vo.SysTenantVo;
import org.dromara.system.domain.vo.SysTenantVoToTenantListVoMapper__4;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__117.class,
    uses = {SysTenantVoToTenantListVoMapper__4.class},
    imports = {}
)
public interface TenantListVoToSysTenantVoMapper__4 extends BaseMapper<TenantListVo, SysTenantVo> {
}
