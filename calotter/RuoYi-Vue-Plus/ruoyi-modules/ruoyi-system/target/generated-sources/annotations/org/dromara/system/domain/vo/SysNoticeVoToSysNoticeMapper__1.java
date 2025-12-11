package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__137;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysNotice;
import org.dromara.system.domain.SysNoticeToSysNoticeVoMapper__1;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__137.class,
    uses = {SysNoticeToSysNoticeVoMapper__1.class},
    imports = {}
)
public interface SysNoticeVoToSysNoticeMapper__1 extends BaseMapper<SysNoticeVo, SysNotice> {
}
