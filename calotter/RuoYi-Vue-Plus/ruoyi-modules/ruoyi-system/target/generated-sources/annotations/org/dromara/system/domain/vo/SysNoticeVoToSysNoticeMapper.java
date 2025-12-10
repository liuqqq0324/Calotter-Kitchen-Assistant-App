package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__54;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysNotice;
import org.dromara.system.domain.SysNoticeToSysNoticeVoMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__54.class,
    uses = {SysNoticeToSysNoticeVoMapper.class},
    imports = {}
)
public interface SysNoticeVoToSysNoticeMapper extends BaseMapper<SysNoticeVo, SysNotice> {
}
