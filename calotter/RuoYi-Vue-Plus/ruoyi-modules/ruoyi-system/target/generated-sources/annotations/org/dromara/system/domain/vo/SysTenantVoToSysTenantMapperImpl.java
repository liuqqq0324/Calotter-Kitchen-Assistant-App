package org.dromara.system.domain.vo;

import javax.annotation.processing.Generated;
import org.dromara.system.domain.SysTenant;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-10T15:10:35+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class SysTenantVoToSysTenantMapperImpl implements SysTenantVoToSysTenantMapper {

    @Override
    public SysTenant convert(SysTenantVo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        SysTenant sysTenant = new SysTenant();

        sysTenant.setAccountCount( arg0.getAccountCount() );
        sysTenant.setAddress( arg0.getAddress() );
        sysTenant.setCompanyName( arg0.getCompanyName() );
        sysTenant.setContactPhone( arg0.getContactPhone() );
        sysTenant.setContactUserName( arg0.getContactUserName() );
        sysTenant.setDomain( arg0.getDomain() );
        sysTenant.setExpireTime( arg0.getExpireTime() );
        sysTenant.setId( arg0.getId() );
        sysTenant.setIntro( arg0.getIntro() );
        sysTenant.setLicenseNumber( arg0.getLicenseNumber() );
        sysTenant.setPackageId( arg0.getPackageId() );
        sysTenant.setRemark( arg0.getRemark() );
        sysTenant.setStatus( arg0.getStatus() );
        sysTenant.setTenantId( arg0.getTenantId() );

        return sysTenant;
    }

    @Override
    public SysTenant convert(SysTenantVo arg0, SysTenant arg1) {
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
