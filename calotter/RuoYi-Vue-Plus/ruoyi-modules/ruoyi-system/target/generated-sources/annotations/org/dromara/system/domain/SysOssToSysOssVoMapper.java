package org.dromara.system.domain;

<<<<<<< HEAD
import io.github.linpeilie.AutoMapperConfig__54;
=======
import io.github.linpeilie.AutoMapperConfig__12;
>>>>>>> chase/flutter-v1-android-java
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysOssBoToSysOssMapper;
import org.dromara.system.domain.vo.SysOssVo;
import org.dromara.system.domain.vo.SysOssVoToSysOssMapper;
import org.mapstruct.Mapper;

@Mapper(
<<<<<<< HEAD
    config = AutoMapperConfig__54.class,
=======
    config = AutoMapperConfig__12.class,
>>>>>>> chase/flutter-v1-android-java
    uses = {SysOssBoToSysOssMapper.class,SysOssVoToSysOssMapper.class},
    imports = {}
)
public interface SysOssToSysOssVoMapper extends BaseMapper<SysOss, SysOssVo> {
}
