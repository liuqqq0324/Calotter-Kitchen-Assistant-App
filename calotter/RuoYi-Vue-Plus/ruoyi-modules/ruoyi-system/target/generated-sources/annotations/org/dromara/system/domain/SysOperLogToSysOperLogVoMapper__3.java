package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__114;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysOperLogBoToSysOperLogMapper__3;
import org.dromara.system.domain.vo.SysOperLogVo;
import org.dromara.system.domain.vo.SysOperLogVoToSysOperLogMapper__3;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__114.class,
    uses = {SysOperLogVoToSysOperLogMapper__3.class,SysOperLogBoToSysOperLogMapper__3.class},
    imports = {}
)
public interface SysOperLogToSysOperLogVoMapper__3 extends BaseMapper<SysOperLog, SysOperLogVo> {
}
