package com.calotter.user.domain.bo;

import com.calotter.user.domain.RolePreference;
import java.util.LinkedHashMap;
import java.util.Map;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T14:28:56+1300",
    comments = "version: 1.6.3, compiler: javac, environment: Java 21.0.8 (JetBrains s.r.o.)"
)
@Component
public class RolePreferenceBoToRolePreferenceMapperImpl implements RolePreferenceBoToRolePreferenceMapper {

    @Override
    public RolePreference convert(RolePreferenceBo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        RolePreference rolePreference = new RolePreference();

        rolePreference.setSearchValue( arg0.getSearchValue() );
        rolePreference.setCreateDept( arg0.getCreateDept() );
        rolePreference.setCreateBy( arg0.getCreateBy() );
        rolePreference.setCreateTime( arg0.getCreateTime() );
        rolePreference.setUpdateBy( arg0.getUpdateBy() );
        rolePreference.setUpdateTime( arg0.getUpdateTime() );
        Map<String, Object> map = arg0.getParams();
        if ( map != null ) {
            rolePreference.setParams( new LinkedHashMap<String, Object>( map ) );
        }
        rolePreference.setId( arg0.getId() );
        rolePreference.setRoleId( arg0.getRoleId() );
        rolePreference.setPreferenceId( arg0.getPreferenceId() );
        rolePreference.setLevel( arg0.getLevel() );

        return rolePreference;
    }

    @Override
    public RolePreference convert(RolePreferenceBo arg0, RolePreference arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setSearchValue( arg0.getSearchValue() );
        arg1.setCreateDept( arg0.getCreateDept() );
        arg1.setCreateBy( arg0.getCreateBy() );
        arg1.setCreateTime( arg0.getCreateTime() );
        arg1.setUpdateBy( arg0.getUpdateBy() );
        arg1.setUpdateTime( arg0.getUpdateTime() );
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
        arg1.setId( arg0.getId() );
        arg1.setRoleId( arg0.getRoleId() );
        arg1.setPreferenceId( arg0.getPreferenceId() );
        arg1.setLevel( arg0.getLevel() );

        return arg1;
    }
}
