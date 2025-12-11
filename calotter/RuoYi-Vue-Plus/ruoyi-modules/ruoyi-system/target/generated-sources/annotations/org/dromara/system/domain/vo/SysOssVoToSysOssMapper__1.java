package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__137;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysOss;
import org.dromara.system.domain.SysOssToSysOssVoMapper__1;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__137.class,
    uses = {SysOssToSysOssVoMapper__1.class},
    imports = {}
)
public interface SysOssVoToSysOssMapper__1 extends BaseMapper<SysOssVo, SysOss> {
}
