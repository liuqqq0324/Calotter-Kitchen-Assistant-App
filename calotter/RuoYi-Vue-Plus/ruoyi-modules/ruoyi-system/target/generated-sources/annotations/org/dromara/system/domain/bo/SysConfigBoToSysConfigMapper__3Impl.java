package org.dromara.system.domain.bo;

import java.util.LinkedHashMap;
import java.util.Map;
import javax.annotation.processing.Generated;
import org.dromara.system.domain.SysConfig;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T11:30:23+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class SysConfigBoToSysConfigMapper__3Impl implements SysConfigBoToSysConfigMapper__3 {

    @Override
    public SysConfig convert(SysConfigBo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        SysConfig sysConfig = new SysConfig();

        sysConfig.setCreateBy( arg0.getCreateBy() );
        sysConfig.setCreateDept( arg0.getCreateDept() );
        sysConfig.setCreateTime( arg0.getCreateTime() );
        Map<String, Object> map = arg0.getParams();
        if ( map != null ) {
            sysConfig.setParams( new LinkedHashMap<String, Object>( map ) );
        }
        sysConfig.setSearchValue( arg0.getSearchValue() );
        sysConfig.setUpdateBy( arg0.getUpdateBy() );
        sysConfig.setUpdateTime( arg0.getUpdateTime() );
        sysConfig.setConfigId( arg0.getConfigId() );
        sysConfig.setConfigKey( arg0.getConfigKey() );
        sysConfig.setConfigName( arg0.getConfigName() );
        sysConfig.setConfigType( arg0.getConfigType() );
        sysConfig.setConfigValue( arg0.getConfigValue() );
        sysConfig.setRemark( arg0.getRemark() );

        return sysConfig;
    }

    @Override
    public SysConfig convert(SysConfigBo arg0, SysConfig arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setCreateBy( arg0.getCreateBy() );
        arg1.setCreateDept( arg0.getCreateDept() );
        arg1.setCreateTime( arg0.getCreateTime() );
        if ( arg1.getParams() != null ) {
            Map<String, Object> map = arg0.getParams();
            if ( map != null ) {
                arg1.getParams().clear();
                arg1.getParams().putAll( map );
            }
            else {
                arg1.setParams( null );
            }
        }
        else {
            Map<String, Object> map = arg0.getParams();
            if ( map != null ) {
                arg1.setParams( new LinkedHashMap<String, Object>( map ) );
            }
        }
        arg1.setSearchValue( arg0.getSearchValue() );
        arg1.setUpdateBy( arg0.getUpdateBy() );
        arg1.setUpdateTime( arg0.getUpdateTime() );
        arg1.setConfigId( arg0.getConfigId() );
        arg1.setConfigKey( arg0.getConfigKey() );
        arg1.setConfigName( arg0.getConfigName() );
        arg1.setConfigType( arg0.getConfigType() );
        arg1.setConfigValue( arg0.getConfigValue() );
        arg1.setRemark( arg0.getRemark() );

        return arg1;
    }
}
