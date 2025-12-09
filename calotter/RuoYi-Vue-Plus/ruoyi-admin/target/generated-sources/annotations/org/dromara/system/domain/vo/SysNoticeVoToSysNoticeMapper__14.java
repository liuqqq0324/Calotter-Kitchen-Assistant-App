package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__40;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysNotice;
import org.dromara.system.domain.SysNoticeToSysNoticeVoMapper__14;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__40.class,
    uses = {SysNoticeToSysNoticeVoMapper__14.class},
    imports = {}
)
public interface SysNoticeVoToSysNoticeMapper__14 extends BaseMapper<SysNoticeVo, SysNotice> {
}
