package org.dromara.system.domain.vo;

import io.github.linpeilie.AutoMapperConfig__114;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.SysOss;
import org.dromara.system.domain.SysOssToSysOssVoMapper__3;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__114.class,
    uses = {SysOssToSysOssVoMapper__3.class},
    imports = {}
)
public interface SysOssVoToSysOssMapper__3 extends BaseMapper<SysOssVo, SysOss> {
}
