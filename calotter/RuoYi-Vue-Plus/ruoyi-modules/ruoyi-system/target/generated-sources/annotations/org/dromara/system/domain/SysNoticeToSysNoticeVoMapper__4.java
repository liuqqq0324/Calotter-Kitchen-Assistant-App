package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__38;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysNoticeBoToSysNoticeMapper__4;
import org.dromara.system.domain.vo.SysNoticeVo;
import org.dromara.system.domain.vo.SysNoticeVoToSysNoticeMapper__4;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__38.class,
    uses = {SysNoticeVoToSysNoticeMapper__4.class,SysNoticeBoToSysNoticeMapper__4.class},
    imports = {}
)
public interface SysNoticeToSysNoticeVoMapper__4 extends BaseMapper<SysNotice, SysNoticeVo> {
}
