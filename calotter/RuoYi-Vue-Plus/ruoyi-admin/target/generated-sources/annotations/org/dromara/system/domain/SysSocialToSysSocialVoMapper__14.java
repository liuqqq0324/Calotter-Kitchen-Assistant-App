package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__40;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysSocialBoToSysSocialMapper__14;
import org.dromara.system.domain.vo.SysSocialVo;
import org.dromara.system.domain.vo.SysSocialVoToSysSocialMapper__14;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__40.class,
    uses = {SysSocialBoToSysSocialMapper__14.class,SysSocialVoToSysSocialMapper__14.class},
    imports = {}
)
public interface SysSocialToSysSocialVoMapper__14 extends BaseMapper<SysSocial, SysSocialVo> {
}
