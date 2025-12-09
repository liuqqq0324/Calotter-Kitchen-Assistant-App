package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__40;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysOperLogBoToSysOperLogMapper__29;
import org.dromara.system.domain.vo.SysOperLogVo;
import org.dromara.system.domain.vo.SysOperLogVoToSysOperLogMapper__14;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__40.class,
    uses = {SysOperLogVoToSysOperLogMapper__14.class,SysOperLogBoToSysOperLogMapper__29.class},
    imports = {}
)
public interface SysOperLogToSysOperLogVoMapper__14 extends BaseMapper<SysOperLog, SysOperLogVo> {
}
