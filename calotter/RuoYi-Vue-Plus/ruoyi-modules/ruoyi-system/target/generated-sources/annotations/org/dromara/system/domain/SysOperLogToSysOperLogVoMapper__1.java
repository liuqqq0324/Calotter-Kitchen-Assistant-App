package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__137;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysOperLogBoToSysOperLogMapper__1;
import org.dromara.system.domain.vo.SysOperLogVo;
import org.dromara.system.domain.vo.SysOperLogVoToSysOperLogMapper__1;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__137.class,
    uses = {SysOperLogVoToSysOperLogMapper__1.class,SysOperLogBoToSysOperLogMapper__1.class},
    imports = {}
)
public interface SysOperLogToSysOperLogVoMapper__1 extends BaseMapper<SysOperLog, SysOperLogVo> {
}
