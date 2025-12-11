package org.dromara.system.domain.vo;

import javax.annotation.processing.Generated;
import org.dromara.system.domain.SysClient;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T13:58:01+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class SysClientVoToSysClientMapper__3Impl implements SysClientVoToSysClientMapper__3 {

    @Override
    public SysClient convert(SysClientVo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        SysClient sysClient = new SysClient();

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
    public SysClient convert(SysClientVo arg0, SysClient arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

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
