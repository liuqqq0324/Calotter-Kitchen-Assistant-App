package org.dromara.common.log.event;

import io.github.linpeilie.AutoMapperConfig__117;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysOperLogBo;
import org.dromara.system.domain.bo.SysOperLogBoToOperLogEventMapper__4;
import org.dromara.system.domain.bo.SysOperLogBoToSysOperLogMapper__4;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__117.class,
    uses = {SysOperLogBoToSysOperLogMapper__4.class,SysOperLogBoToOperLogEventMapper__4.class},
    imports = {}
)
public interface OperLogEventToSysOperLogBoMapper__4 extends BaseMapper<OperLogEvent, SysOperLogBo> {
}
