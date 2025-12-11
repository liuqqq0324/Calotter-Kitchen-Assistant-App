package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__114;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysNoticeBoToSysNoticeMapper__3;
import org.dromara.system.domain.vo.SysNoticeVo;
import org.dromara.system.domain.vo.SysNoticeVoToSysNoticeMapper__3;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__114.class,
    uses = {SysNoticeVoToSysNoticeMapper__3.class,SysNoticeBoToSysNoticeMapper__3.class},
    imports = {}
)
public interface SysNoticeToSysNoticeVoMapper__3 extends BaseMapper<SysNotice, SysNoticeVo> {
}
