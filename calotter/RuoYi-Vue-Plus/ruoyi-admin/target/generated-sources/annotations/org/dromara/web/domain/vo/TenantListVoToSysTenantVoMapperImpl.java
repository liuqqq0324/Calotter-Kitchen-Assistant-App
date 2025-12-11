package org.dromara.web.domain.vo;

import javax.annotation.processing.Generated;
import org.dromara.system.domain.vo.SysTenantVo;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T16:50:04+1300",
    comments = "version: 1.6.3, compiler: javac, environment: Java 25.0.1 (Homebrew)"
)
@Component
public class TenantListVoToSysTenantVoMapperImpl implements TenantListVoToSysTenantVoMapper {

    @Override
    public SysTenantVo convert(TenantListVo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        SysTenantVo sysTenantVo = new SysTenantVo();

        sysTenantVo.setTenantId( arg0.getTenantId() );
        sysTenantVo.setCompanyName( arg0.getCompanyName() );
        sysTenantVo.setDomain( arg0.getDomain() );

        return sysTenantVo;
    }

    @Override
    public SysTenantVo convert(TenantListVo arg0, SysTenantVo arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setTenantId( arg0.getTenantId() );
        arg1.setCompanyName( arg0.getCompanyName() );
        arg1.setDomain( arg0.getDomain() );

        return arg1;
    }
}
