package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__114;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysOperLog;
import org.dromara.system.domain.SysOperLogToSysOperLogVoMapper__3;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__114.class,
    uses = {SysOperLogToSysOperLogVoMapper__3.class},
    imports = {}
)
public interface SysOperLogVoToSysOperLogMapper__3 extends BaseMapper<SysOperLogVo, SysOperLog> {
}
