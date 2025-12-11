package com.calotter.user.domain.bo;

import com.calotter.user.domain.User;
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
public class UserBoToUserMapperImpl implements UserBoToUserMapper {

    @Override
    public User convert(UserBo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        User user = new User();

        user.setSearchValue( arg0.getSearchValue() );
        user.setCreateDept( arg0.getCreateDept() );
        user.setCreateBy( arg0.getCreateBy() );
        user.setCreateTime( arg0.getCreateTime() );
        user.setUpdateBy( arg0.getUpdateBy() );
        user.setUpdateTime( arg0.getUpdateTime() );
        Map<String, Object> map = arg0.getParams();
        if ( map != null ) {
            user.setParams( new LinkedHashMap<String, Object>( map ) );
        }
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
    public User convert(UserBo arg0, User arg1) {
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
