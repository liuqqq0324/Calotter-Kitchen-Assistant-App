package com.calotter.user.domain;

import com.calotter.user.domain.vo.UserRoleVo;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T14:28:56+1300",
    comments = "version: 1.6.3, compiler: javac, environment: Java 21.0.8 (JetBrains s.r.o.)"
)
@Component
public class UserRoleToUserRoleVoMapperImpl implements UserRoleToUserRoleVoMapper {

    @Override
    public UserRoleVo convert(UserRole arg0) {
        if ( arg0 == null ) {
            return null;
        }

        UserRoleVo userRoleVo = new UserRoleVo();

        userRoleVo.setId( arg0.getId() );
        userRoleVo.setUserId( arg0.getUserId() );
        userRoleVo.setName( arg0.getName() );
        userRoleVo.setAccountOwner( arg0.getAccountOwner() );
        userRoleVo.setGender( arg0.getGender() );
        userRoleVo.setBirthdate( arg0.getBirthdate() );

        return userRoleVo;
    }

    @Override
    public UserRoleVo convert(UserRole arg0, UserRoleVo arg1) {
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
