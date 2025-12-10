package org.dromara.system.domain.vo;

import javax.annotation.processing.Generated;
import org.dromara.system.domain.SysConfig;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-10T13:27:22+1300",
    comments = "version: 1.6.3, compiler: javac, environment: Java 25.0.1 (Homebrew)"
)
@Component
public class SysConfigVoToSysConfigMapperImpl implements SysConfigVoToSysConfigMapper {

    @Override
    public SysConfig convert(SysConfigVo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        SysConfig sysConfig = new SysConfig();

        sysConfig.setCreateTime( arg0.getCreateTime() );
        sysConfig.setConfigId( arg0.getConfigId() );
        sysConfig.setConfigName( arg0.getConfigName() );
        sysConfig.setConfigKey( arg0.getConfigKey() );
        sysConfig.setConfigValue( arg0.getConfigValue() );
        sysConfig.setConfigType( arg0.getConfigType() );
        sysConfig.setRemark( arg0.getRemark() );

        return sysConfig;
    }

    @Override
    public SysConfig convert(SysConfigVo arg0, SysConfig arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setCreateTime( arg0.getCreateTime() );
        arg1.setConfigId( arg0.getConfigId() );
        arg1.setConfigName( arg0.getConfigName() );
        arg1.setConfigKey( arg0.getConfigKey() );
        arg1.setConfigValue( arg0.getConfigValue() );
        arg1.setConfigType( arg0.getConfigType() );
        arg1.setRemark( arg0.getRemark() );

        return arg1;
    }
}
