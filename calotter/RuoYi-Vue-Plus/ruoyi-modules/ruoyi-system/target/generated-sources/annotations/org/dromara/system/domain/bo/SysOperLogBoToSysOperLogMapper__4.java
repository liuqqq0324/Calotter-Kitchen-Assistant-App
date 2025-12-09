package org.dromara.system.domain.bo;

import io.github.linpeilie.AutoMapperConfig__38;
import io.github.linpeilie.BaseMapper;
import org.dromara.common.log.event.OperLogEventToSysOperLogBoMapper__4;
import org.dromara.system.domain.SysOperLog;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__38.class,
    uses = {SysOperLogBoToOperLogEventMapper__4.class,OperLogEventToSysOperLogBoMapper__4.class},
    imports = {}
)
public interface SysOperLogBoToSysOperLogMapper__4 extends BaseMapper<SysOperLogBo, SysOperLog> {
}
