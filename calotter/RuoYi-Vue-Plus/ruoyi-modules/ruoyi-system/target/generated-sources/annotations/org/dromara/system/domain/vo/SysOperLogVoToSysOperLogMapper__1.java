package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__137;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysOperLog;
import org.dromara.system.domain.SysOperLogToSysOperLogVoMapper__1;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__137.class,
    uses = {SysOperLogToSysOperLogVoMapper__1.class},
    imports = {}
)
public interface SysOperLogVoToSysOperLogMapper__1 extends BaseMapper<SysOperLogVo, SysOperLog> {
}
