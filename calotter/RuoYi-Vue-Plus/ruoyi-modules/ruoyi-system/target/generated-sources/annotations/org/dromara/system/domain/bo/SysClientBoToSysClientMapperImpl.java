package org.dromara.system.domain.bo;

import java.util.LinkedHashMap;
import java.util.Map;
import javax.annotation.processing.Generated;
import org.dromara.system.domain.SysClient;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-10T12:08:12+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class SysClientBoToSysClientMapperImpl implements SysClientBoToSysClientMapper {

    @Override
    public SysClient convert(SysClientBo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        SysClient sysClient = new SysClient();

        sysClient.setCreateBy( arg0.getCreateBy() );
        sysClient.setCreateDept( arg0.getCreateDept() );
        sysClient.setCreateTime( arg0.getCreateTime() );
        Map<String, Object> map = arg0.getParams();
        if ( map != null ) {
            sysClient.setParams( new LinkedHashMap<String, Object>( map ) );
        }
        sysClient.setSearchValue( arg0.getSearchValue() );
        sysClient.setUpdateBy( arg0.getUpdateBy() );
        sysClient.setUpdateTime( arg0.getUpdateTime() );
        sysClient.setActiveTimeout( arg0.getActiveTimeout() );
        sysClient.setClientId( arg0.getClientId() );
        sysClient.setClientKey( arg0.getClientKey() );
        sysClient.setClientSecret( arg0.getClientSecret() );
        sysClient.setDeviceType( arg0.getDeviceType() );
        sysClient.setGrantType( arg0.getGrantType() );
        sysClient.setId( arg0.getId() );
        sysClient.setStatus( arg0.getStatus() );
        sysClient.setTimeout( arg0.getTimeout() );

        return sysClient;
    }

    @Override
    public SysClient convert(SysClientBo arg0, SysClient arg1) {
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
        arg1.setActiveTimeout( arg0.getActiveTimeout() );
        arg1.setClientId( arg0.getClientId() );
        arg1.setClientKey( arg0.getClientKey() );
        arg1.setClientSecret( arg0.getClientSecret() );
        arg1.setDeviceType( arg0.getDeviceType() );
        arg1.setGrantType( arg0.getGrantType() );
        arg1.setId( arg0.getId() );
        arg1.setStatus( arg0.getStatus() );
        arg1.setTimeout( arg0.getTimeout() );

        return arg1;
    }
}
