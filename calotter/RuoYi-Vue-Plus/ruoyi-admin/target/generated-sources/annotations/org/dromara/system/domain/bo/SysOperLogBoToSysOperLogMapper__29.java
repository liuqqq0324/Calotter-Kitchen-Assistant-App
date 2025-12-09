package org.dromara.system.domain.bo;

import io.github.linpeilie.AutoMapperConfig__40;
import io.github.linpeilie.BaseMapper;
import org.dromara.common.log.event.OperLogEventToSysOperLogBoMapper__29;
import org.dromara.system.domain.SysOperLog;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__40.class,
    uses = {SysOperLogBoToOperLogEventMapper__29.class,OperLogEventToSysOperLogBoMapper__29.class},
    imports = {}
)
public interface SysOperLogBoToSysOperLogMapper__29 extends BaseMapper<SysOperLogBo, SysOperLog> {
}
