package org.dromara.system.domain.bo;

import io.github.linpeilie.AutoMapperConfig__35;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysNotice;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__35.class,
    uses = {},
    imports = {}
)
public interface SysNoticeBoToSysNoticeMapper extends BaseMapper<SysNoticeBo, SysNotice> {
}
