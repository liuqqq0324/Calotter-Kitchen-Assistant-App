package com.calotter.user.domain;

import com.calotter.user.domain.vo.UserVo;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T13:57:48+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class UserToUserVoMapperImpl implements UserToUserVoMapper {

    @Override
    public UserVo convert(User arg0) {
        if ( arg0 == null ) {
            return null;
        }

        UserVo userVo = new UserVo();

        userVo.setAvatarUrl( arg0.getAvatarUrl() );
        userVo.setDisplayName( arg0.getDisplayName() );
        userVo.setEmail( arg0.getEmail() );
        userVo.setId( arg0.getId() );
        userVo.setLastLoginAt( arg0.getLastLoginAt() );
        userVo.setPasswordHash( arg0.getPasswordHash() );
        userVo.setStatus( arg0.getStatus() );
        userVo.setUsername( arg0.getUsername() );

        return userVo;
    }

    @Override
    public UserVo convert(User arg0, UserVo arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setAvatarUrl( arg0.getAvatarUrl() );
        arg1.setDisplayName( arg0.getDisplayName() );
        arg1.setEmail( arg0.getEmail() );
        arg1.setId( arg0.getId() );
        arg1.setLastLoginAt( arg0.getLastLoginAt() );
        arg1.setPasswordHash( arg0.getPasswordHash() );
        arg1.setStatus( arg0.getStatus() );
        arg1.setUsername( arg0.getUsername() );

        return arg1;
    }
}
