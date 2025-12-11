package com.calotter.user.domain.bo;

import com.calotter.user.domain.User;
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
public class UserBoToUserMapperImpl implements UserBoToUserMapper {

    @Override
    public User convert(UserBo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        User user = new User();

        user.setCreateBy( arg0.getCreateBy() );
        user.setCreateDept( arg0.getCreateDept() );
        user.setCreateTime( arg0.getCreateTime() );
        Map<String, Object> map = arg0.getParams();
        if ( map != null ) {
            user.setParams( new LinkedHashMap<String, Object>( map ) );
        }
        user.setSearchValue( arg0.getSearchValue() );
        user.setUpdateBy( arg0.getUpdateBy() );
        user.setUpdateTime( arg0.getUpdateTime() );
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
    public User convert(UserBo arg0, User arg1) {
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
