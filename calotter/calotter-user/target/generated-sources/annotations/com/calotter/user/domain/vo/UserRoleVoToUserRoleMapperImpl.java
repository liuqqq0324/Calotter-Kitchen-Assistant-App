package com.calotter.user.domain.vo;

import com.calotter.user.domain.UserRole;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T13:57:48+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class UserRoleVoToUserRoleMapperImpl implements UserRoleVoToUserRoleMapper {

    @Override
    public UserRole convert(UserRoleVo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        UserRole userRole = new UserRole();

        userRole.setAccountOwner( arg0.getAccountOwner() );
        userRole.setBirthdate( arg0.getBirthdate() );
        userRole.setGender( arg0.getGender() );
        userRole.setId( arg0.getId() );
        userRole.setName( arg0.getName() );
        userRole.setUserId( arg0.getUserId() );

        return userRole;
    }

    @Override
    public UserRole convert(UserRoleVo arg0, UserRole arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setAccountOwner( arg0.getAccountOwner() );
        arg1.setBirthdate( arg0.getBirthdate() );
        arg1.setGender( arg0.getGender() );
        arg1.setId( arg0.getId() );
        arg1.setName( arg0.getName() );
        arg1.setUserId( arg0.getUserId() );

        return arg1;
    }
}
