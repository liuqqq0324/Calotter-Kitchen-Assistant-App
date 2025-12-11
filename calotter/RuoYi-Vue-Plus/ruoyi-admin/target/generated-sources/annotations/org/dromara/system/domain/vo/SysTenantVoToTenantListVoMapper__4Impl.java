package org.dromara.system.domain.vo;

import javax.annotation.processing.Generated;
import org.dromara.web.domain.vo.TenantListVo;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T11:30:49+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class SysTenantVoToTenantListVoMapper__4Impl implements SysTenantVoToTenantListVoMapper__4 {

    @Override
    public TenantListVo convert(SysTenantVo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        TenantListVo tenantListVo = new TenantListVo();

        tenantListVo.setCompanyName( arg0.getCompanyName() );
        tenantListVo.setDomain( arg0.getDomain() );
        tenantListVo.setTenantId( arg0.getTenantId() );

        return tenantListVo;
    }

    @Override
    public TenantListVo convert(SysTenantVo arg0, TenantListVo arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setCompanyName( arg0.getCompanyName() );
        arg1.setDomain( arg0.getDomain() );
        arg1.setTenantId( arg0.getTenantId() );

        return arg1;
    }
}
