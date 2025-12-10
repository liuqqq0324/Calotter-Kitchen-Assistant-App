package org.dromara.system.domain;

import javax.annotation.processing.Generated;
import org.dromara.system.domain.vo.SysLogininforVo;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-10T15:10:37+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class SysLogininforToSysLogininforVoMapper__4Impl implements SysLogininforToSysLogininforVoMapper__4 {

    @Override
    public SysLogininforVo convert(SysLogininfor arg0) {
        if ( arg0 == null ) {
            return null;
        }

        SysLogininforVo sysLogininforVo = new SysLogininforVo();

        sysLogininforVo.setBrowser( arg0.getBrowser() );
        sysLogininforVo.setClientKey( arg0.getClientKey() );
        sysLogininforVo.setDeviceType( arg0.getDeviceType() );
        sysLogininforVo.setInfoId( arg0.getInfoId() );
        sysLogininforVo.setIpaddr( arg0.getIpaddr() );
        sysLogininforVo.setLoginLocation( arg0.getLoginLocation() );
        sysLogininforVo.setLoginTime( arg0.getLoginTime() );
        sysLogininforVo.setMsg( arg0.getMsg() );
        sysLogininforVo.setOs( arg0.getOs() );
        sysLogininforVo.setStatus( arg0.getStatus() );
        sysLogininforVo.setTenantId( arg0.getTenantId() );
        sysLogininforVo.setUserName( arg0.getUserName() );

        return sysLogininforVo;
    }

    @Override
    public SysLogininforVo convert(SysLogininfor arg0, SysLogininforVo arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setBrowser( arg0.getBrowser() );
        arg1.setClientKey( arg0.getClientKey() );
        arg1.setDeviceType( arg0.getDeviceType() );
        arg1.setInfoId( arg0.getInfoId() );
        arg1.setIpaddr( arg0.getIpaddr() );
        arg1.setLoginLocation( arg0.getLoginLocation() );
        arg1.setLoginTime( arg0.getLoginTime() );
        arg1.setMsg( arg0.getMsg() );
        arg1.setOs( arg0.getOs() );
        arg1.setStatus( arg0.getStatus() );
        arg1.setTenantId( arg0.getTenantId() );
        arg1.setUserName( arg0.getUserName() );

        return arg1;
    }
}
