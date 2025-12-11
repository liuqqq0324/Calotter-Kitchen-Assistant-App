package org.dromara.system.domain.bo;

import io.github.linpeilie.AutoMapperConfig__114;
import io.github.linpeilie.BaseMapper;
import org.dromara.common.log.event.OperLogEvent;
import org.dromara.common.log.event.OperLogEventToSysOperLogBoMapper__3;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__114.class,
    uses = {SysOperLogBoToSysOperLogMapper__3.class,OperLogEventToSysOperLogBoMapper__3.class},
    imports = {}
)
public interface SysOperLogBoToOperLogEventMapper__3 extends BaseMapper<SysOperLogBo, OperLogEvent> {
}
