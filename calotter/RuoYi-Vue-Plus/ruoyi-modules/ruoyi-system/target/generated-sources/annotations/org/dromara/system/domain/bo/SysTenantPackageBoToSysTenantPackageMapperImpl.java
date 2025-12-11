package org.dromara.system.domain.bo;

import java.util.LinkedHashMap;
import java.util.Map;
import javax.annotation.processing.Generated;
import org.dromara.system.domain.SysTenantPackage;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T16:49:58+1300",
    comments = "version: 1.6.3, compiler: javac, environment: Java 25.0.1 (Homebrew)"
)
@Component
public class SysTenantPackageBoToSysTenantPackageMapperImpl implements SysTenantPackageBoToSysTenantPackageMapper {

    @Override
    public SysTenantPackage convert(SysTenantPackageBo source) {
        if ( source == null ) {
            return null;
        }

        SysTenantPackage sysTenantPackage = new SysTenantPackage();

        sysTenantPackage.setSearchValue( source.getSearchValue() );
        sysTenantPackage.setCreateDept( source.getCreateDept() );
        sysTenantPackage.setCreateBy( source.getCreateBy() );
        sysTenantPackage.setCreateTime( source.getCreateTime() );
        sysTenantPackage.setUpdateBy( source.getUpdateBy() );
        sysTenantPackage.setUpdateTime( source.getUpdateTime() );
        Map<String, Object> map = source.getParams();
        if ( map != null ) {
            sysTenantPackage.setParams( new LinkedHashMap<String, Object>( map ) );
        }
        sysTenantPackage.setPackageId( source.getPackageId() );
        sysTenantPackage.setPackageName( source.getPackageName() );
        sysTenantPackage.setRemark( source.getRemark() );
        sysTenantPackage.setMenuCheckStrictly( source.getMenuCheckStrictly() );
        sysTenantPackage.setStatus( source.getStatus() );

        sysTenantPackage.setMenuIds( org.dromara.common.core.utils.StringUtils.joinComma(source.getMenuIds()) );

        return sysTenantPackage;
    }

    @Override
    public SysTenantPackage convert(SysTenantPackageBo source, SysTenantPackage target) {
        if ( source == null ) {
            return target;
        }

        target.setSearchValue( source.getSearchValue() );
        target.setCreateDept( source.getCreateDept() );
        target.setCreateBy( source.getCreateBy() );
        target.setCreateTime( source.getCreateTime() );
        target.setUpdateBy( source.getUpdateBy() );
        target.setUpdateTime( source.getUpdateTime() );
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
        target.setPackageId( source.getPackageId() );
        target.setPackageName( source.getPackageName() );
        target.setRemark( source.getRemark() );
        target.setMenuCheckStrictly( source.getMenuCheckStrictly() );
        target.setStatus( source.getStatus() );

        target.setMenuIds( org.dromara.common.core.utils.StringUtils.joinComma(source.getMenuIds()) );

        return target;
    }
}
