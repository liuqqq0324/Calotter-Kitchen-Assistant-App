package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__38;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysOss;
import org.dromara.system.domain.SysOssToSysOssVoMapper__4;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__38.class,
    uses = {SysOssToSysOssVoMapper__4.class},
    imports = {}
)
public interface SysOssVoToSysOssMapper__4 extends BaseMapper<SysOssVo, SysOss> {
}
