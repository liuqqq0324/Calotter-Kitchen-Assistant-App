package com.calotter.user.domain.bo;

import com.calotter.user.domain.UserRole;
import java.util.LinkedHashMap;
import java.util.Map;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T17:42:11+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class UserRoleBoToUserRoleMapperImpl implements UserRoleBoToUserRoleMapper {

    @Override
    public UserRole convert(UserRoleBo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        UserRole userRole = new UserRole();

        userRole.setCreateBy( arg0.getCreateBy() );
        userRole.setCreateDept( arg0.getCreateDept() );
        userRole.setCreateTime( arg0.getCreateTime() );
        Map<String, Object> map = arg0.getParams();
        if ( map != null ) {
            userRole.setParams( new LinkedHashMap<String, Object>( map ) );
        }
        userRole.setSearchValue( arg0.getSearchValue() );
        userRole.setUpdateBy( arg0.getUpdateBy() );
        userRole.setUpdateTime( arg0.getUpdateTime() );
        userRole.setAccountOwner( arg0.getAccountOwner() );
        userRole.setBirthdate( arg0.getBirthdate() );
        userRole.setGender( arg0.getGender() );
        userRole.setId( arg0.getId() );
        userRole.setName( arg0.getName() );
        userRole.setUserId( arg0.getUserId() );

        return userRole;
    }

    @Override
    public UserRole convert(UserRoleBo arg0, UserRole arg1) {
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
        arg1.setAccountOwner( arg0.getAccountOwner() );
        arg1.setBirthdate( arg0.getBirthdate() );
        arg1.setGender( arg0.getGender() );
        arg1.setId( arg0.getId() );
        arg1.setName( arg0.getName() );
        arg1.setUserId( arg0.getUserId() );

        return arg1;
    }
}
