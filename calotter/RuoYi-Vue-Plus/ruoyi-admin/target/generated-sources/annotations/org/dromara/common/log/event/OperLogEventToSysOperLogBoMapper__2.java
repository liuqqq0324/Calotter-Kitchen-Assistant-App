package org.dromara.common.log.event;

import io.github.linpeilie.AutoMapperConfig__40;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysOperLogBo;
import org.dromara.system.domain.bo.SysOperLogBoToOperLogEventMapper__2;
import org.dromara.system.domain.bo.SysOperLogBoToSysOperLogMapper__2;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__40.class,
    uses = {SysOperLogBoToSysOperLogMapper__2.class,SysOperLogBoToOperLogEventMapper__2.class},
    imports = {}
)
public interface OperLogEventToSysOperLogBoMapper__2 extends BaseMapper<OperLogEvent, SysOperLogBo> {
}
