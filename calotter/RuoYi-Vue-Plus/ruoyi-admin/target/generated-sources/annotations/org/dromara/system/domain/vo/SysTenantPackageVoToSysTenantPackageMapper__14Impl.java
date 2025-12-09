package org.dromara.system.domain.vo;

import javax.annotation.processing.Generated;
import org.dromara.system.domain.SysTenantPackage;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-10T12:23:26+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class SysTenantPackageVoToSysTenantPackageMapper__14Impl implements SysTenantPackageVoToSysTenantPackageMapper__14 {

    @Override
    public SysTenantPackage convert(SysTenantPackageVo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        SysTenantPackage sysTenantPackage = new SysTenantPackage();

        sysTenantPackage.setPackageId( arg0.getPackageId() );
        sysTenantPackage.setPackageName( arg0.getPackageName() );
        sysTenantPackage.setMenuIds( arg0.getMenuIds() );
        sysTenantPackage.setRemark( arg0.getRemark() );
        sysTenantPackage.setMenuCheckStrictly( arg0.getMenuCheckStrictly() );
        sysTenantPackage.setStatus( arg0.getStatus() );

        return sysTenantPackage;
    }

    @Override
    public SysTenantPackage convert(SysTenantPackageVo arg0, SysTenantPackage arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setPackageId( arg0.getPackageId() );
        arg1.setPackageName( arg0.getPackageName() );
        arg1.setMenuIds( arg0.getMenuIds() );
        arg1.setRemark( arg0.getRemark() );
        arg1.setMenuCheckStrictly( arg0.getMenuCheckStrictly() );
        arg1.setStatus( arg0.getStatus() );

        return arg1;
    }
}
