package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__114;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysNotice;
import org.dromara.system.domain.SysNoticeToSysNoticeVoMapper__3;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__114.class,
    uses = {SysNoticeToSysNoticeVoMapper__3.class},
    imports = {}
)
public interface SysNoticeVoToSysNoticeMapper__3 extends BaseMapper<SysNoticeVo, SysNotice> {
}
