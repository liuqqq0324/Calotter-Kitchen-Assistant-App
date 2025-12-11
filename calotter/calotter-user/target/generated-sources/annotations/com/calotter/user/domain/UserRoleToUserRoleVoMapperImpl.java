package com.calotter.user.domain;

import com.calotter.user.domain.vo.UserRoleVo;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T13:57:48+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class UserRoleToUserRoleVoMapperImpl implements UserRoleToUserRoleVoMapper {

    @Override
    public UserRoleVo convert(UserRole arg0) {
        if ( arg0 == null ) {
            return null;
        }

        UserRoleVo userRoleVo = new UserRoleVo();

        userRoleVo.setAccountOwner( arg0.getAccountOwner() );
        userRoleVo.setBirthdate( arg0.getBirthdate() );
        userRoleVo.setGender( arg0.getGender() );
        userRoleVo.setId( arg0.getId() );
        userRoleVo.setName( arg0.getName() );
        userRoleVo.setUserId( arg0.getUserId() );

        return userRoleVo;
    }

    @Override
    public UserRoleVo convert(UserRole arg0, UserRoleVo arg1) {
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
