package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__40;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysOssBoToSysOssMapper__14;
import org.dromara.system.domain.vo.SysOssVo;
import org.dromara.system.domain.vo.SysOssVoToSysOssMapper__14;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__40.class,
    uses = {SysOssBoToSysOssMapper__14.class,SysOssVoToSysOssMapper__14.class},
    imports = {}
)
public interface SysOssToSysOssVoMapper__14 extends BaseMapper<SysOss, SysOssVo> {
}
