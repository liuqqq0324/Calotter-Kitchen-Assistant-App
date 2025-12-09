package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__40;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysPostBoToSysPostMapper__14;
import org.dromara.system.domain.vo.SysPostVo;
import org.dromara.system.domain.vo.SysPostVoToSysPostMapper__14;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__40.class,
    uses = {SysPostBoToSysPostMapper__14.class,SysPostVoToSysPostMapper__14.class},
    imports = {}
)
public interface SysPostToSysPostVoMapper__14 extends BaseMapper<SysPost, SysPostVo> {
}
