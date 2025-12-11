package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__114;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysSocialBoToSysSocialMapper__3;
import org.dromara.system.domain.vo.SysSocialVo;
import org.dromara.system.domain.vo.SysSocialVoToSysSocialMapper__3;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__114.class,
    uses = {SysSocialBoToSysSocialMapper__3.class,SysSocialVoToSysSocialMapper__3.class},
    imports = {}
)
public interface SysSocialToSysSocialVoMapper__3 extends BaseMapper<SysSocial, SysSocialVo> {
}
