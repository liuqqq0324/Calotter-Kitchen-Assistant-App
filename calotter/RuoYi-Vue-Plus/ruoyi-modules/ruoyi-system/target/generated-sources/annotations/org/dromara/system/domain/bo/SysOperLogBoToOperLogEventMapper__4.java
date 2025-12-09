package org.dromara.system.domain.bo;

import io.github.linpeilie.AutoMapperConfig__38;
import io.github.linpeilie.BaseMapper;
import org.dromara.common.log.event.OperLogEvent;
import org.dromara.common.log.event.OperLogEventToSysOperLogBoMapper__4;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__38.class,
    uses = {SysOperLogBoToSysOperLogMapper__4.class,OperLogEventToSysOperLogBoMapper__4.class},
    imports = {}
)
public interface SysOperLogBoToOperLogEventMapper__4 extends BaseMapper<SysOperLogBo, OperLogEvent> {
}
