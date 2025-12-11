package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__114;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysOssBoToSysOssMapper__3;
import org.dromara.system.domain.vo.SysOssVo;
import org.dromara.system.domain.vo.SysOssVoToSysOssMapper__3;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__114.class,
    uses = {SysOssBoToSysOssMapper__3.class,SysOssVoToSysOssMapper__3.class},
    imports = {}
)
public interface SysOssToSysOssVoMapper__3 extends BaseMapper<SysOss, SysOssVo> {
}
