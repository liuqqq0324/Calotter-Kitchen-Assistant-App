package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__40;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysNoticeBoToSysNoticeMapper__14;
import org.dromara.system.domain.vo.SysNoticeVo;
import org.dromara.system.domain.vo.SysNoticeVoToSysNoticeMapper__14;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__40.class,
    uses = {SysNoticeVoToSysNoticeMapper__14.class,SysNoticeBoToSysNoticeMapper__14.class},
    imports = {}
)
public interface SysNoticeToSysNoticeVoMapper__14 extends BaseMapper<SysNotice, SysNoticeVo> {
}
