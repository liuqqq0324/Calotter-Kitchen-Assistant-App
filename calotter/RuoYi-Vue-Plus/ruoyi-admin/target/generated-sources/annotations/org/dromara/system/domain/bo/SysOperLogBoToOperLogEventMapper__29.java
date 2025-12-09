package org.dromara.system.domain.bo;

import io.github.linpeilie.AutoMapperConfig__40;
import io.github.linpeilie.BaseMapper;
import org.dromara.common.log.event.OperLogEvent;
import org.dromara.common.log.event.OperLogEventToSysOperLogBoMapper__29;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__40.class,
    uses = {SysOperLogBoToSysOperLogMapper__29.class,OperLogEventToSysOperLogBoMapper__29.class},
    imports = {}
)
public interface SysOperLogBoToOperLogEventMapper__29 extends BaseMapper<SysOperLogBo, OperLogEvent> {
}
