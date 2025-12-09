package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__38;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysNotice;
import org.dromara.system.domain.SysNoticeToSysNoticeVoMapper__4;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__38.class,
    uses = {SysNoticeToSysNoticeVoMapper__4.class},
    imports = {}
)
public interface SysNoticeVoToSysNoticeMapper__4 extends BaseMapper<SysNoticeVo, SysNotice> {
}
