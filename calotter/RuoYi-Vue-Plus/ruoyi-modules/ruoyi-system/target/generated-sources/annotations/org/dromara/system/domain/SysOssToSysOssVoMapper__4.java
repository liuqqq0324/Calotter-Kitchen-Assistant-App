package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__38;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysOssBoToSysOssMapper__4;
import org.dromara.system.domain.vo.SysOssVo;
import org.dromara.system.domain.vo.SysOssVoToSysOssMapper__4;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__38.class,
    uses = {SysOssBoToSysOssMapper__4.class,SysOssVoToSysOssMapper__4.class},
    imports = {}
)
public interface SysOssToSysOssVoMapper__4 extends BaseMapper<SysOss, SysOssVo> {
}
