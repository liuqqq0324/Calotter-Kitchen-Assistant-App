package org.dromara.system.domain.bo;

import io.github.linpeilie.AutoMapperConfig__137;
import io.github.linpeilie.BaseMapper;
import org.dromara.common.log.event.OperLogEvent;
import org.dromara.common.log.event.OperLogEventToSysOperLogBoMapper__1;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__137.class,
    uses = {SysOperLogBoToSysOperLogMapper__1.class,OperLogEventToSysOperLogBoMapper__1.class},
    imports = {}
)
public interface SysOperLogBoToOperLogEventMapper__1 extends BaseMapper<SysOperLogBo, OperLogEvent> {
}
