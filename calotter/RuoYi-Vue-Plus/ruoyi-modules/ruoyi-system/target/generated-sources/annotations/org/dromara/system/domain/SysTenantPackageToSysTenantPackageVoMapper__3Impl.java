package org.dromara.system.domain;

import javax.annotation.processing.Generated;
import org.dromara.system.domain.vo.SysTenantPackageVo;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T13:58:01+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class SysTenantPackageToSysTenantPackageVoMapper__3Impl implements SysTenantPackageToSysTenantPackageVoMapper__3 {

    @Override
    public SysTenantPackageVo convert(SysTenantPackage arg0) {
        if ( arg0 == null ) {
            return null;
        }

        SysTenantPackageVo sysTenantPackageVo = new SysTenantPackageVo();

        sysTenantPackageVo.setMenuCheckStrictly( arg0.getMenuCheckStrictly() );
        sysTenantPackageVo.setMenuIds( arg0.getMenuIds() );
        sysTenantPackageVo.setPackageId( arg0.getPackageId() );
        sysTenantPackageVo.setPackageName( arg0.getPackageName() );
        sysTenantPackageVo.setRemark( arg0.getRemark() );
        sysTenantPackageVo.setStatus( arg0.getStatus() );

        return sysTenantPackageVo;
    }

    @Override
    public SysTenantPackageVo convert(SysTenantPackage arg0, SysTenantPackageVo arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setMenuCheckStrictly( arg0.getMenuCheckStrictly() );
        arg1.setMenuIds( arg0.getMenuIds() );
        arg1.setPackageId( arg0.getPackageId() );
        arg1.setPackageName( arg0.getPackageName() );
        arg1.setRemark( arg0.getRemark() );
        arg1.setStatus( arg0.getStatus() );

        return arg1;
    }
}
