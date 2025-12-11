package org.dromara.system.domain;

<<<<<<< HEAD
import io.github.linpeilie.AutoMapperConfig__54;
=======
import io.github.linpeilie.AutoMapperConfig__12;
>>>>>>> chase/flutter-v1-android-java
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysOperLogBoToSysOperLogMapper;
import org.dromara.system.domain.vo.SysOperLogVo;
import org.dromara.system.domain.vo.SysOperLogVoToSysOperLogMapper;
import org.mapstruct.Mapper;

@Mapper(
<<<<<<< HEAD
    config = AutoMapperConfig__54.class,
=======
    config = AutoMapperConfig__12.class,
>>>>>>> chase/flutter-v1-android-java
    uses = {SysOperLogVoToSysOperLogMapper.class,SysOperLogBoToSysOperLogMapper.class},
    imports = {}
)
public interface SysOperLogToSysOperLogVoMapper extends BaseMapper<SysOperLog, SysOperLogVo> {
}
