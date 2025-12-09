package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__40;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysOss;
import org.dromara.system.domain.SysOssToSysOssVoMapper__14;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__40.class,
    uses = {SysOssToSysOssVoMapper__14.class},
    imports = {}
)
public interface SysOssVoToSysOssMapper__14 extends BaseMapper<SysOssVo, SysOss> {
}
