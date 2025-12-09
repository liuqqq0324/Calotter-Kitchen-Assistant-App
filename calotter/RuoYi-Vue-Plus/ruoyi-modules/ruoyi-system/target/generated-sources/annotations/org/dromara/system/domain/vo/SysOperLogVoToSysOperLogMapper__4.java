package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__38;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysOperLog;
import org.dromara.system.domain.SysOperLogToSysOperLogVoMapper__4;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__38.class,
    uses = {SysOperLogToSysOperLogVoMapper__4.class},
    imports = {}
)
public interface SysOperLogVoToSysOperLogMapper__4 extends BaseMapper<SysOperLogVo, SysOperLog> {
}
