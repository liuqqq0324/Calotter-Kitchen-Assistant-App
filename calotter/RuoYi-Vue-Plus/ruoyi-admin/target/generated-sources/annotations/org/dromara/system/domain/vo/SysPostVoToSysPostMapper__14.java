package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__40;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysPost;
import org.dromara.system.domain.SysPostToSysPostVoMapper__14;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__40.class,
    uses = {SysPostToSysPostVoMapper__14.class},
    imports = {}
)
public interface SysPostVoToSysPostMapper__14 extends BaseMapper<SysPostVo, SysPost> {
}
