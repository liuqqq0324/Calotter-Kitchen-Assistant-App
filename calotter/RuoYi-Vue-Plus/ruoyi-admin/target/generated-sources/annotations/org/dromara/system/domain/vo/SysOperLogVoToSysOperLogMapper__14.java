package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__40;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysOperLog;
import org.dromara.system.domain.SysOperLogToSysOperLogVoMapper__14;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__40.class,
    uses = {SysOperLogToSysOperLogVoMapper__14.class},
    imports = {}
)
public interface SysOperLogVoToSysOperLogMapper__14 extends BaseMapper<SysOperLogVo, SysOperLog> {
}
