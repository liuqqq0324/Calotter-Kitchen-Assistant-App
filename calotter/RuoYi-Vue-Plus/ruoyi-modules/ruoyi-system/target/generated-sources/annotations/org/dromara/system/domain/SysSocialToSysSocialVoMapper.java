package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__12;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysSocialBoToSysSocialMapper;
import org.dromara.system.domain.vo.SysSocialVo;
import org.dromara.system.domain.vo.SysSocialVoToSysSocialMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__12.class,
    uses = {SysSocialBoToSysSocialMapper.class,SysSocialVoToSysSocialMapper.class},
    imports = {}
)
public interface SysSocialToSysSocialVoMapper extends BaseMapper<SysSocial, SysSocialVo> {
}
