package org.dromara.system.domain;

import javax.annotation.processing.Generated;
import org.dromara.system.domain.vo.SysClientVo;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T16:49:58+1300",
    comments = "version: 1.6.3, compiler: javac, environment: Java 25.0.1 (Homebrew)"
)
@Component
public class SysClientToSysClientVoMapperImpl implements SysClientToSysClientVoMapper {

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
