package org.dromara.system.domain.bo;

import io.github.linpeilie.AutoMapperConfig__137;
import io.github.linpeilie.BaseMapper;
import org.dromara.common.log.event.OperLogEventToSysOperLogBoMapper__1;
import org.dromara.system.domain.SysOperLog;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__137.class,
    uses = {SysOperLogBoToOperLogEventMapper__1.class,OperLogEventToSysOperLogBoMapper__1.class},
    imports = {}
)
public interface SysOperLogBoToSysOperLogMapper__1 extends BaseMapper<SysOperLogBo, SysOperLog> {
}
