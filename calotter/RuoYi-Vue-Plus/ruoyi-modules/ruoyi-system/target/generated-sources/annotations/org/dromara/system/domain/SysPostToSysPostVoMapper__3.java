package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__114;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysPostBoToSysPostMapper__3;
import org.dromara.system.domain.vo.SysPostVo;
import org.dromara.system.domain.vo.SysPostVoToSysPostMapper__3;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__114.class,
    uses = {SysPostBoToSysPostMapper__3.class,SysPostVoToSysPostMapper__3.class},
    imports = {}
)
public interface SysPostToSysPostVoMapper__3 extends BaseMapper<SysPost, SysPostVo> {
}
