package org.dromara.system.domain;

import io.github.linpeilie.AutoMapperConfig__35;
import io.github.linpeilie.BaseMapper;
import org.dromara.system.domain.bo.SysOssBoToSysOssMapper;
import org.dromara.system.domain.vo.SysOssVo;
import org.dromara.system.domain.vo.SysOssVoToSysOssMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__35.class,
    uses = {SysOssBoToSysOssMapper.class,SysOssVoToSysOssMapper.class},
    imports = {}
)
public interface SysOssToSysOssVoMapper extends BaseMapper<SysOss, SysOssVo> {
}
