package org.dromara.common.log.event;

import io.github.linpeilie.AutoMapperConfig__137;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysOperLogBo;
import org.dromara.system.domain.bo.SysOperLogBoToOperLogEventMapper__1;
import org.dromara.system.domain.bo.SysOperLogBoToSysOperLogMapper__1;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__137.class,
    uses = {SysOperLogBoToSysOperLogMapper__1.class,SysOperLogBoToOperLogEventMapper__1.class},
    imports = {}
)
public interface OperLogEventToSysOperLogBoMapper__1 extends BaseMapper<OperLogEvent, SysOperLogBo> {
}
