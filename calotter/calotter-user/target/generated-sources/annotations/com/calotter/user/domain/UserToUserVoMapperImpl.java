package com.calotter.user.domain;

import com.calotter.user.domain.vo.UserVo;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T14:28:56+1300",
    comments = "version: 1.6.3, compiler: javac, environment: Java 21.0.8 (JetBrains s.r.o.)"
)
@Component
public class UserToUserVoMapperImpl implements UserToUserVoMapper {

    @Override
    public UserVo convert(User arg0) {
        if ( arg0 == null ) {
            return null;
        }

        UserVo userVo = new UserVo();

        userVo.setId( arg0.getId() );
        userVo.setUsername( arg0.getUsername() );
        userVo.setEmail( arg0.getEmail() );
        userVo.setPasswordHash( arg0.getPasswordHash() );
        userVo.setDisplayName( arg0.getDisplayName() );
        userVo.setAvatarUrl( arg0.getAvatarUrl() );
        userVo.setLastLoginAt( arg0.getLastLoginAt() );
        userVo.setStatus( arg0.getStatus() );

        return userVo;
    }

    @Override
    public UserVo convert(User arg0, UserVo arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setId( arg0.getId() );
        arg1.setUsername( arg0.getUsername() );
        arg1.setEmail( arg0.getEmail() );
        arg1.setPasswordHash( arg0.getPasswordHash() );
        arg1.setDisplayName( arg0.getDisplayName() );
        arg1.setAvatarUrl( arg0.getAvatarUrl() );
        arg1.setLastLoginAt( arg0.getLastLoginAt() );
        arg1.setStatus( arg0.getStatus() );

        return arg1;
    }
}
