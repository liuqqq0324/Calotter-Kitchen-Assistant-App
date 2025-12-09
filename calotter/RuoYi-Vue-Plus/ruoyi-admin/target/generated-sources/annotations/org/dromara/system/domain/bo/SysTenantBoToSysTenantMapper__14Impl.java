package org.dromara.system.domain.bo;

import java.util.LinkedHashMap;
import java.util.Map;
import javax.annotation.processing.Generated;
import org.dromara.system.domain.SysTenant;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-10T12:23:25+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class SysTenantBoToSysTenantMapper__14Impl implements SysTenantBoToSysTenantMapper__14 {

    @Override
    public SysTenant convert(SysTenantBo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        SysTenant sysTenant = new SysTenant();

        sysTenant.setCreateBy( arg0.getCreateBy() );
        sysTenant.setCreateDept( arg0.getCreateDept() );
        sysTenant.setCreateTime( arg0.getCreateTime() );
        Map<String, Object> map = arg0.getParams();
        if ( map != null ) {
            sysTenant.setParams( new LinkedHashMap<String, Object>( map ) );
        }
        sysTenant.setSearchValue( arg0.getSearchValue() );
        sysTenant.setUpdateBy( arg0.getUpdateBy() );
        sysTenant.setUpdateTime( arg0.getUpdateTime() );
        sysTenant.setId( arg0.getId() );
        sysTenant.setTenantId( arg0.getTenantId() );
        sysTenant.setContactUserName( arg0.getContactUserName() );
        sysTenant.setContactPhone( arg0.getContactPhone() );
        sysTenant.setCompanyName( arg0.getCompanyName() );
        sysTenant.setLicenseNumber( arg0.getLicenseNumber() );
        sysTenant.setAddress( arg0.getAddress() );
        sysTenant.setDomain( arg0.getDomain() );
        sysTenant.setIntro( arg0.getIntro() );
        sysTenant.setRemark( arg0.getRemark() );
        sysTenant.setPackageId( arg0.getPackageId() );
        sysTenant.setExpireTime( arg0.getExpireTime() );
        sysTenant.setAccountCount( arg0.getAccountCount() );
        sysTenant.setStatus( arg0.getStatus() );

        return sysTenant;
    }

    @Override
    public SysTenant convert(SysTenantBo arg0, SysTenant arg1) {
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
        arg1.setId( arg0.getId() );
        arg1.setTenantId( arg0.getTenantId() );
        arg1.setContactUserName( arg0.getContactUserName() );
        arg1.setContactPhone( arg0.getContactPhone() );
        arg1.setCompanyName( arg0.getCompanyName() );
        arg1.setLicenseNumber( arg0.getLicenseNumber() );
        arg1.setAddress( arg0.getAddress() );
        arg1.setDomain( arg0.getDomain() );
        arg1.setIntro( arg0.getIntro() );
        arg1.setRemark( arg0.getRemark() );
        arg1.setPackageId( arg0.getPackageId() );
        arg1.setExpireTime( arg0.getExpireTime() );
        arg1.setAccountCount( arg0.getAccountCount() );
        arg1.setStatus( arg0.getStatus() );

        return arg1;
    }
}
