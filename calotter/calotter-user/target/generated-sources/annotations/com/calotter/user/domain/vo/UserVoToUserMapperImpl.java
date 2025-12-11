package com.calotter.user.domain.vo;

import com.calotter.user.domain.User;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T14:28:56+1300",
    comments = "version: 1.6.3, compiler: javac, environment: Java 21.0.8 (JetBrains s.r.o.)"
)
@Component
public class UserVoToUserMapperImpl implements UserVoToUserMapper {

    @Override
    public User convert(UserVo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        User user = new User();

        user.setId( arg0.getId() );
        user.setUsername( arg0.getUsername() );
        user.setEmail( arg0.getEmail() );
        user.setPasswordHash( arg0.getPasswordHash() );
        user.setDisplayName( arg0.getDisplayName() );
        user.setAvatarUrl( arg0.getAvatarUrl() );
        user.setLastLoginAt( arg0.getLastLoginAt() );
        user.setStatus( arg0.getStatus() );

        return user;
    }

    @Override
    public User convert(UserVo arg0, User arg1) {
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
