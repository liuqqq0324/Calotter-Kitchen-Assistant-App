package org.dromara.system.domain.bo;

import java.util.LinkedHashMap;
import java.util.Map;
import javax.annotation.processing.Generated;
import org.dromara.system.domain.SysTenantPackage;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-10T15:10:35+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class SysTenantPackageBoToSysTenantPackageMapper__4Impl implements SysTenantPackageBoToSysTenantPackageMapper__4 {

    @Override
    public SysTenantPackage convert(SysTenantPackageBo source) {
        if ( source == null ) {
            return null;
        }

        SysTenantPackage sysTenantPackage = new SysTenantPackage();

        sysTenantPackage.setCreateBy( source.getCreateBy() );
        sysTenantPackage.setCreateDept( source.getCreateDept() );
        sysTenantPackage.setCreateTime( source.getCreateTime() );
        Map<String, Object> map = source.getParams();
        if ( map != null ) {
            sysTenantPackage.setParams( new LinkedHashMap<String, Object>( map ) );
        }
        sysTenantPackage.setSearchValue( source.getSearchValue() );
        sysTenantPackage.setUpdateBy( source.getUpdateBy() );
        sysTenantPackage.setUpdateTime( source.getUpdateTime() );
        sysTenantPackage.setMenuCheckStrictly( source.getMenuCheckStrictly() );
        sysTenantPackage.setPackageId( source.getPackageId() );
        sysTenantPackage.setPackageName( source.getPackageName() );
        sysTenantPackage.setRemark( source.getRemark() );
        sysTenantPackage.setStatus( source.getStatus() );

        sysTenantPackage.setMenuIds( org.dromara.common.core.utils.StringUtils.joinComma(source.getMenuIds()) );

        return sysTenantPackage;
    }

    @Override
    public SysTenantPackage convert(SysTenantPackageBo source, SysTenantPackage target) {
        if ( source == null ) {
            return target;
        }

        target.setCreateBy( source.getCreateBy() );
        target.setCreateDept( source.getCreateDept() );
        target.setCreateTime( source.getCreateTime() );
        if ( target.getParams() != null ) {
            Map<String, Object> map = source.getParams();
            if ( map != null ) {
                target.getParams().clear();
                target.getParams().putAll( map );
            }
            else {
                target.setParams( null );
            }
        }
        else {
            Map<String, Object> map = source.getParams();
            if ( map != null ) {
                target.setParams( new LinkedHashMap<String, Object>( map ) );
            }
        }
        target.setSearchValue( source.getSearchValue() );
        target.setUpdateBy( source.getUpdateBy() );
        target.setUpdateTime( source.getUpdateTime() );
        target.setMenuCheckStrictly( source.getMenuCheckStrictly() );
        target.setPackageId( source.getPackageId() );
        target.setPackageName( source.getPackageName() );
        target.setRemark( source.getRemark() );
        target.setStatus( source.getStatus() );

        target.setMenuIds( org.dromara.common.core.utils.StringUtils.joinComma(source.getMenuIds()) );

        return target;
    }
}
