package com.calotter.user.domain.vo;

import com.calotter.user.domain.UserRole;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T14:28:56+1300",
    comments = "version: 1.6.3, compiler: javac, environment: Java 21.0.8 (JetBrains s.r.o.)"
)
@Component
public class UserRoleVoToUserRoleMapperImpl implements UserRoleVoToUserRoleMapper {

    @Override
    public UserRole convert(UserRoleVo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        UserRole userRole = new UserRole();

        userRole.setId( arg0.getId() );
        userRole.setUserId( arg0.getUserId() );
        userRole.setName( arg0.getName() );
        userRole.setAccountOwner( arg0.getAccountOwner() );
        userRole.setGender( arg0.getGender() );
        userRole.setBirthdate( arg0.getBirthdate() );

        return userRole;
    }

    @Override
    public UserRole convert(UserRoleVo arg0, UserRole arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setId( arg0.getId() );
        arg1.setUserId( arg0.getUserId() );
        arg1.setName( arg0.getName() );
        arg1.setAccountOwner( arg0.getAccountOwner() );
        arg1.setGender( arg0.getGender() );
        arg1.setBirthdate( arg0.getBirthdate() );

        return arg1;
    }
}
