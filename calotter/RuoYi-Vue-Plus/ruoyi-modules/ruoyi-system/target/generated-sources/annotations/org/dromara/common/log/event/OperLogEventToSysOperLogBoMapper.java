package org.dromara.common.log.event;

<<<<<<< HEAD
import io.github.linpeilie.AutoMapperConfig__54;
=======
import io.github.linpeilie.AutoMapperConfig__12;
>>>>>>> chase/flutter-v1-android-java
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysOperLogBo;
import org.dromara.system.domain.bo.SysOperLogBoToOperLogEventMapper;
import org.dromara.system.domain.bo.SysOperLogBoToSysOperLogMapper;
import org.mapstruct.Mapper;

@Mapper(
<<<<<<< HEAD
    config = AutoMapperConfig__54.class,
=======
    config = AutoMapperConfig__12.class,
>>>>>>> chase/flutter-v1-android-java
    uses = {SysOperLogBoToSysOperLogMapper.class,SysOperLogBoToOperLogEventMapper.class},
    imports = {}
)
public interface OperLogEventToSysOperLogBoMapper extends BaseMapper<OperLogEvent, SysOperLogBo> {
}
