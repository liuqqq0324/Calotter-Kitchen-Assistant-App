package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__38;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysOperLogBoToSysOperLogMapper__4;
import org.dromara.system.domain.vo.SysOperLogVo;
import org.dromara.system.domain.vo.SysOperLogVoToSysOperLogMapper__4;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__38.class,
    uses = {SysOperLogVoToSysOperLogMapper__4.class,SysOperLogBoToSysOperLogMapper__4.class},
    imports = {}
)
public interface SysOperLogToSysOperLogVoMapper__4 extends BaseMapper<SysOperLog, SysOperLogVo> {
}
