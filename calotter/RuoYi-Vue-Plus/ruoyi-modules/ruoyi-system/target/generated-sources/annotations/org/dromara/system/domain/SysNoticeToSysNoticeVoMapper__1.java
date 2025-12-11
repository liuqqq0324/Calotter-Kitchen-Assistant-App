package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__137;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysNoticeBoToSysNoticeMapper__1;
import org.dromara.system.domain.vo.SysNoticeVo;
import org.dromara.system.domain.vo.SysNoticeVoToSysNoticeMapper__1;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__137.class,
    uses = {SysNoticeVoToSysNoticeMapper__1.class,SysNoticeBoToSysNoticeMapper__1.class},
    imports = {}
)
public interface SysNoticeToSysNoticeVoMapper__1 extends BaseMapper<SysNotice, SysNoticeVo> {
}
