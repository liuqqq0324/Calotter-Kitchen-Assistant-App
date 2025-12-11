package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__137;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysPost;
import org.dromara.system.domain.SysPostToSysPostVoMapper__1;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__137.class,
    uses = {SysPostToSysPostVoMapper__1.class},
    imports = {}
)
public interface SysPostVoToSysPostMapper__1 extends BaseMapper<SysPostVo, SysPost> {
}
