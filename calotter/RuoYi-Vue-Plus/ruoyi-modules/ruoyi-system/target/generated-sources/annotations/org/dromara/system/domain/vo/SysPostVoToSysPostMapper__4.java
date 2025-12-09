package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__38;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysPost;
import org.dromara.system.domain.SysPostToSysPostVoMapper__4;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__38.class,
    uses = {SysPostToSysPostVoMapper__4.class},
    imports = {}
)
public interface SysPostVoToSysPostMapper__4 extends BaseMapper<SysPostVo, SysPost> {
}
