package org.dromara.system.domain.vo;

import javax.annotation.processing.Generated;
import org.dromara.system.domain.SysLogininfor;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-10T12:23:14+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
public class SysLogininforVoToSysLogininforMapperImpl implements SysLogininforVoToSysLogininforMapper {

    @Override
    public SysLogininfor convert(SysLogininforVo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        SysLogininfor sysLogininfor = new SysLogininfor();

        sysLogininfor.setBrowser( arg0.getBrowser() );
        sysLogininfor.setClientKey( arg0.getClientKey() );
        sysLogininfor.setDeviceType( arg0.getDeviceType() );
        sysLogininfor.setInfoId( arg0.getInfoId() );
        sysLogininfor.setIpaddr( arg0.getIpaddr() );
        sysLogininfor.setLoginLocation( arg0.getLoginLocation() );
        sysLogininfor.setLoginTime( arg0.getLoginTime() );
        sysLogininfor.setMsg( arg0.getMsg() );
        sysLogininfor.setOs( arg0.getOs() );
        sysLogininfor.setStatus( arg0.getStatus() );
        sysLogininfor.setTenantId( arg0.getTenantId() );
        sysLogininfor.setUserName( arg0.getUserName() );

        return sysLogininfor;
    }

    @Override
    public SysLogininfor convert(SysLogininforVo arg0, SysLogininfor arg1) {
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
