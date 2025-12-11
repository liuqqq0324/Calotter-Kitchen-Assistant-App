package org.dromara.system.domain;

import javax.annotation.processing.Generated;
import org.dromara.system.domain.vo.SysLogininforVo;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T16:49:58+1300",
    comments = "version: 1.6.3, compiler: javac, environment: Java 25.0.1 (Homebrew)"
)
@Component
public class SysLogininforToSysLogininforVoMapperImpl implements SysLogininforToSysLogininforVoMapper {

    @Override
    public SysLogininforVo convert(SysLogininfor arg0) {
        if ( arg0 == null ) {
            return null;
        }

        SysLogininforVo sysLogininforVo = new SysLogininforVo();

        sysLogininforVo.setInfoId( arg0.getInfoId() );
        sysLogininforVo.setTenantId( arg0.getTenantId() );
        sysLogininforVo.setUserName( arg0.getUserName() );
        sysLogininforVo.setClientKey( arg0.getClientKey() );
        sysLogininforVo.setDeviceType( arg0.getDeviceType() );
        sysLogininforVo.setStatus( arg0.getStatus() );
        sysLogininforVo.setIpaddr( arg0.getIpaddr() );
        sysLogininforVo.setLoginLocation( arg0.getLoginLocation() );
        sysLogininforVo.setBrowser( arg0.getBrowser() );
        sysLogininforVo.setOs( arg0.getOs() );
        sysLogininforVo.setMsg( arg0.getMsg() );
        sysLogininforVo.setLoginTime( arg0.getLoginTime() );

        return sysLogininforVo;
    }

    @Override
    public SysLogininforVo convert(SysLogininfor arg0, SysLogininforVo arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setInfoId( arg0.getInfoId() );
        arg1.setTenantId( arg0.getTenantId() );
        arg1.setUserName( arg0.getUserName() );
        arg1.setClientKey( arg0.getClientKey() );
        arg1.setDeviceType( arg0.getDeviceType() );
        arg1.setStatus( arg0.getStatus() );
        arg1.setIpaddr( arg0.getIpaddr() );
        arg1.setLoginLocation( arg0.getLoginLocation() );
        arg1.setBrowser( arg0.getBrowser() );
        arg1.setOs( arg0.getOs() );
        arg1.setMsg( arg0.getMsg() );
        arg1.setLoginTime( arg0.getLoginTime() );

        return arg1;
    }
}
