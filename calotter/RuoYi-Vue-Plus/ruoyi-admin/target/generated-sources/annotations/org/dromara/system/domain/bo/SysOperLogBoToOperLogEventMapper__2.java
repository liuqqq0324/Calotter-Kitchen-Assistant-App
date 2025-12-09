package org.dromara.system.domain.bo;

import io.github.linpeilie.AutoMapperConfig__40;
import io.github.linpeilie.BaseMapper;
import org.dromara.common.log.event.OperLogEvent;
import org.dromara.common.log.event.OperLogEventToSysOperLogBoMapper__2;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__40.class,
    uses = {SysOperLogBoToSysOperLogMapper__2.class,OperLogEventToSysOperLogBoMapper__2.class},
    imports = {}
)
public interface SysOperLogBoToOperLogEventMapper__2 extends BaseMapper<SysOperLogBo, OperLogEvent> {
}
