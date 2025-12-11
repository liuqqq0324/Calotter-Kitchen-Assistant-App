package org.dromara.common.log.event;

import io.github.linpeilie.AutoMapperConfig__114;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysOperLogBo;
import org.dromara.system.domain.bo.SysOperLogBoToOperLogEventMapper__3;
import org.dromara.system.domain.bo.SysOperLogBoToSysOperLogMapper__3;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__114.class,
    uses = {SysOperLogBoToSysOperLogMapper__3.class,SysOperLogBoToOperLogEventMapper__3.class},
    imports = {}
)
public interface OperLogEventToSysOperLogBoMapper__3 extends BaseMapper<OperLogEvent, SysOperLogBo> {
}
