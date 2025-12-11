package org.dromara.system.domain.vo;

<<<<<<< HEAD
import io.github.linpeilie.AutoMapperConfig__54;
=======
import io.github.linpeilie.AutoMapperConfig__12;
>>>>>>> chase/flutter-v1-android-java
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysNotice;
import org.dromara.system.domain.SysNoticeToSysNoticeVoMapper;
import org.mapstruct.Mapper;

@Mapper(
<<<<<<< HEAD
    config = AutoMapperConfig__54.class,
=======
    config = AutoMapperConfig__12.class,
>>>>>>> chase/flutter-v1-android-java
    uses = {SysNoticeToSysNoticeVoMapper.class},
    imports = {}
)
public interface SysNoticeVoToSysNoticeMapper extends BaseMapper<SysNoticeVo, SysNotice> {
}
