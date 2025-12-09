package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__38;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysPostBoToSysPostMapper__4;
import org.dromara.system.domain.vo.SysPostVo;
import org.dromara.system.domain.vo.SysPostVoToSysPostMapper__4;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__38.class,
    uses = {SysPostBoToSysPostMapper__4.class,SysPostVoToSysPostMapper__4.class},
    imports = {}
)
public interface SysPostToSysPostVoMapper__4 extends BaseMapper<SysPost, SysPostVo> {
}
