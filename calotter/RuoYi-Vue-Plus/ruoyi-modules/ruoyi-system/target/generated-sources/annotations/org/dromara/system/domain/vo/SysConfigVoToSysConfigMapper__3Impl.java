package org.dromara.system.domain.vo;

import javax.annotation.processing.Generated;
import org.dromara.system.domain.SysConfig;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T11:30:23+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class SysConfigVoToSysConfigMapper__3Impl implements SysConfigVoToSysConfigMapper__3 {

    @Override
    public SysConfig convert(SysConfigVo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        SysConfig sysConfig = new SysConfig();

        sysConfig.setCreateTime( arg0.getCreateTime() );
        sysConfig.setConfigId( arg0.getConfigId() );
        sysConfig.setConfigKey( arg0.getConfigKey() );
        sysConfig.setConfigName( arg0.getConfigName() );
        sysConfig.setConfigType( arg0.getConfigType() );
        sysConfig.setConfigValue( arg0.getConfigValue() );
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
        arg1.setConfigKey( arg0.getConfigKey() );
        arg1.setConfigName( arg0.getConfigName() );
        arg1.setConfigType( arg0.getConfigType() );
        arg1.setConfigValue( arg0.getConfigValue() );
        arg1.setRemark( arg0.getRemark() );

        return arg1;
    }
}
