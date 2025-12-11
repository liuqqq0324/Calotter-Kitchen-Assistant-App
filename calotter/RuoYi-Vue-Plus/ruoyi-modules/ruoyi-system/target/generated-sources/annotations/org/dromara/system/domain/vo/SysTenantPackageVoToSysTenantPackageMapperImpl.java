package org.dromara.system.domain.vo;

import javax.annotation.processing.Generated;
import org.dromara.system.domain.SysTenantPackage;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T16:49:58+1300",
    comments = "version: 1.6.3, compiler: javac, environment: Java 25.0.1 (Homebrew)"
)
@Component
public class SysTenantPackageVoToSysTenantPackageMapperImpl implements SysTenantPackageVoToSysTenantPackageMapper {

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
