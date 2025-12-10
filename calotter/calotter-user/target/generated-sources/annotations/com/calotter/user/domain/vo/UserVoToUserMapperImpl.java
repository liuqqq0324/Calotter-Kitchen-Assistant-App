package com.calotter.user.domain.vo;

import com.calotter.user.domain.User;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-10T15:10:17+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class UserVoToUserMapperImpl implements UserVoToUserMapper {

    @Override
    public User convert(UserVo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        User user = new User();

        user.setAvatarUrl( arg0.getAvatarUrl() );
        user.setDisplayName( arg0.getDisplayName() );
        user.setEmail( arg0.getEmail() );
        user.setId( arg0.getId() );
        user.setLastLoginAt( arg0.getLastLoginAt() );
        user.setPasswordHash( arg0.getPasswordHash() );
        user.setStatus( arg0.getStatus() );
        user.setUsername( arg0.getUsername() );

        return user;
    }

    @Override
    public User convert(UserVo arg0, User arg1) {
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
