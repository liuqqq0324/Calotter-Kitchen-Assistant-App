package org.dromara.common.log.event;

import io.github.linpeilie.AutoMapperConfig__40;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysOperLogBo;
import org.dromara.system.domain.bo.SysOperLogBoToOperLogEventMapper__29;
import org.dromara.system.domain.bo.SysOperLogBoToSysOperLogMapper__29;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__40.class,
    uses = {SysOperLogBoToSysOperLogMapper__29.class,SysOperLogBoToOperLogEventMapper__29.class},
    imports = {}
)
public interface OperLogEventToSysOperLogBoMapper__29 extends BaseMapper<OperLogEvent, SysOperLogBo> {
}
