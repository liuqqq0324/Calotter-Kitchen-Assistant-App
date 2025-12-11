package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__114;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysPost;
import org.dromara.system.domain.SysPostToSysPostVoMapper__3;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__114.class,
    uses = {SysPostToSysPostVoMapper__3.class},
    imports = {}
)
public interface SysPostVoToSysPostMapper__3 extends BaseMapper<SysPostVo, SysPost> {
}
