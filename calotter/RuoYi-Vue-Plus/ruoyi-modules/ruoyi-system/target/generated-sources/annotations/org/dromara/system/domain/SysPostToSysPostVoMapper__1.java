package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__137;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysPostBoToSysPostMapper__1;
import org.dromara.system.domain.vo.SysPostVo;
import org.dromara.system.domain.vo.SysPostVoToSysPostMapper__1;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__137.class,
    uses = {SysPostBoToSysPostMapper__1.class,SysPostVoToSysPostMapper__1.class},
    imports = {}
)
public interface SysPostToSysPostVoMapper__1 extends BaseMapper<SysPost, SysPostVo> {
}
