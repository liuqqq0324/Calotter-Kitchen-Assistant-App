package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__137;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysSocialBoToSysSocialMapper__1;
import org.dromara.system.domain.vo.SysSocialVo;
import org.dromara.system.domain.vo.SysSocialVoToSysSocialMapper__1;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__137.class,
    uses = {SysSocialBoToSysSocialMapper__1.class,SysSocialVoToSysSocialMapper__1.class},
    imports = {}
)
public interface SysSocialToSysSocialVoMapper__1 extends BaseMapper<SysSocial, SysSocialVo> {
}
