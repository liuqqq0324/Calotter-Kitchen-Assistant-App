package org.dromara.system.domain.vo;

import javax.annotation.processing.Generated;
import org.dromara.system.domain.SysClient;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T17:59:10+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
public class SysClientVoToSysClientMapperImpl implements SysClientVoToSysClientMapper {

    @Override
    public SysClient convert(SysClientVo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        SysClient sysClient = new SysClient();

        sysClient.setId( arg0.getId() );
        sysClient.setClientId( arg0.getClientId() );
        sysClient.setClientKey( arg0.getClientKey() );
        sysClient.setClientSecret( arg0.getClientSecret() );
        sysClient.setGrantType( arg0.getGrantType() );
        sysClient.setDeviceType( arg0.getDeviceType() );
        sysClient.setActiveTimeout( arg0.getActiveTimeout() );
        sysClient.setTimeout( arg0.getTimeout() );
        sysClient.setStatus( arg0.getStatus() );

        return sysClient;
    }

    @Override
    public SysClient convert(SysClientVo arg0, SysClient arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setId( arg0.getId() );
        arg1.setClientId( arg0.getClientId() );
        arg1.setClientKey( arg0.getClientKey() );
        arg1.setClientSecret( arg0.getClientSecret() );
        arg1.setGrantType( arg0.getGrantType() );
        arg1.setDeviceType( arg0.getDeviceType() );
        arg1.setActiveTimeout( arg0.getActiveTimeout() );
        arg1.setTimeout( arg0.getTimeout() );
        arg1.setStatus( arg0.getStatus() );

        return arg1;
    }
}
