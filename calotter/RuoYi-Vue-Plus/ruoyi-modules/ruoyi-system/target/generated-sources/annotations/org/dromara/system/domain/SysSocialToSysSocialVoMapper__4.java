package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__38;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysSocialBoToSysSocialMapper__4;
import org.dromara.system.domain.vo.SysSocialVo;
import org.dromara.system.domain.vo.SysSocialVoToSysSocialMapper__4;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__38.class,
    uses = {SysSocialBoToSysSocialMapper__4.class,SysSocialVoToSysSocialMapper__4.class},
    imports = {}
)
public interface SysSocialToSysSocialVoMapper__4 extends BaseMapper<SysSocial, SysSocialVo> {
}
