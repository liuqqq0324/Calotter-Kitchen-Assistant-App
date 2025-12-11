package com.calotter.user.domain.bo;

import com.calotter.user.domain.RolePreference;
import java.util.LinkedHashMap;
import java.util.Map;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T13:57:48+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class RolePreferenceBoToRolePreferenceMapperImpl implements RolePreferenceBoToRolePreferenceMapper {

    @Override
    public RolePreference convert(RolePreferenceBo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        RolePreference rolePreference = new RolePreference();

        rolePreference.setCreateBy( arg0.getCreateBy() );
        rolePreference.setCreateDept( arg0.getCreateDept() );
        rolePreference.setCreateTime( arg0.getCreateTime() );
        Map<String, Object> map = arg0.getParams();
        if ( map != null ) {
            rolePreference.setParams( new LinkedHashMap<String, Object>( map ) );
        }
        rolePreference.setSearchValue( arg0.getSearchValue() );
        rolePreference.setUpdateBy( arg0.getUpdateBy() );
        rolePreference.setUpdateTime( arg0.getUpdateTime() );
        rolePreference.setId( arg0.getId() );
        rolePreference.setLevel( arg0.getLevel() );
        rolePreference.setPreferenceId( arg0.getPreferenceId() );
        rolePreference.setRoleId( arg0.getRoleId() );

        return rolePreference;
    }

    @Override
    public RolePreference convert(RolePreferenceBo arg0, RolePreference arg1) {
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
        arg1.setLevel( arg0.getLevel() );
        arg1.setPreferenceId( arg0.getPreferenceId() );
        arg1.setRoleId( arg0.getRoleId() );

        return arg1;
    }
}
