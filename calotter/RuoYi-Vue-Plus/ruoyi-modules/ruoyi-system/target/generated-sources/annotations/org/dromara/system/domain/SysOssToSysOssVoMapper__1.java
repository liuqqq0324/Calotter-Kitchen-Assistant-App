package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__137;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysOssBoToSysOssMapper__1;
import org.dromara.system.domain.vo.SysOssVo;
import org.dromara.system.domain.vo.SysOssVoToSysOssMapper__1;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__137.class,
    uses = {SysOssBoToSysOssMapper__1.class,SysOssVoToSysOssMapper__1.class},
    imports = {}
)
public interface SysOssToSysOssVoMapper__1 extends BaseMapper<SysOss, SysOssVo> {
}
