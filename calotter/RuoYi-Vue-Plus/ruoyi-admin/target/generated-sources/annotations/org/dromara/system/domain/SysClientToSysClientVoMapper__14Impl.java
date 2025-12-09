package org.dromara.system.domain;

import javax.annotation.processing.Generated;
import org.dromara.system.domain.vo.SysClientVo;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-10T12:23:25+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class SysClientToSysClientVoMapper__14Impl implements SysClientToSysClientVoMapper__14 {

    @Override
    public SysClientVo convert(SysClient arg0) {
        if ( arg0 == null ) {
            return null;
        }

        SysClientVo sysClientVo = new SysClientVo();

        sysClientVo.setId( arg0.getId() );
        sysClientVo.setClientId( arg0.getClientId() );
        sysClientVo.setClientKey( arg0.getClientKey() );
        sysClientVo.setClientSecret( arg0.getClientSecret() );
        sysClientVo.setGrantType( arg0.getGrantType() );
        sysClientVo.setDeviceType( arg0.getDeviceType() );
        sysClientVo.setActiveTimeout( arg0.getActiveTimeout() );
        sysClientVo.setTimeout( arg0.getTimeout() );
        sysClientVo.setStatus( arg0.getStatus() );

        return sysClientVo;
    }

    @Override
    public SysClientVo convert(SysClient arg0, SysClientVo arg1) {
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
