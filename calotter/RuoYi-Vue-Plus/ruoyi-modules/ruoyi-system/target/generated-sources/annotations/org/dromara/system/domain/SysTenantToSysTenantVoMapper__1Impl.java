package org.dromara.system.domain;

import javax.annotation.processing.Generated;
import org.dromara.system.domain.vo.SysTenantVo;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T13:58:02+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class SysTenantToSysTenantVoMapper__1Impl implements SysTenantToSysTenantVoMapper__1 {

    @Override
    public SysTenantVo convert(SysTenant arg0) {
        if ( arg0 == null ) {
            return null;
        }

        SysTenantVo sysTenantVo = new SysTenantVo();

        sysTenantVo.setAccountCount( arg0.getAccountCount() );
        sysTenantVo.setAddress( arg0.getAddress() );
        sysTenantVo.setCompanyName( arg0.getCompanyName() );
        sysTenantVo.setContactPhone( arg0.getContactPhone() );
        sysTenantVo.setContactUserName( arg0.getContactUserName() );
        sysTenantVo.setDomain( arg0.getDomain() );
        sysTenantVo.setExpireTime( arg0.getExpireTime() );
        sysTenantVo.setId( arg0.getId() );
        sysTenantVo.setIntro( arg0.getIntro() );
        sysTenantVo.setLicenseNumber( arg0.getLicenseNumber() );
        sysTenantVo.setPackageId( arg0.getPackageId() );
        sysTenantVo.setRemark( arg0.getRemark() );
        sysTenantVo.setStatus( arg0.getStatus() );
        sysTenantVo.setTenantId( arg0.getTenantId() );

        return sysTenantVo;
    }

    @Override
    public SysTenantVo convert(SysTenant arg0, SysTenantVo arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setAccountCount( arg0.getAccountCount() );
        arg1.setAddress( arg0.getAddress() );
        arg1.setCompanyName( arg0.getCompanyName() );
        arg1.setContactPhone( arg0.getContactPhone() );
        arg1.setContactUserName( arg0.getContactUserName() );
        arg1.setDomain( arg0.getDomain() );
        arg1.setExpireTime( arg0.getExpireTime() );
        arg1.setId( arg0.getId() );
        arg1.setIntro( arg0.getIntro() );
        arg1.setLicenseNumber( arg0.getLicenseNumber() );
        arg1.setPackageId( arg0.getPackageId() );
        arg1.setRemark( arg0.getRemark() );
        arg1.setStatus( arg0.getStatus() );
        arg1.setTenantId( arg0.getTenantId() );

        return arg1;
    }
}
