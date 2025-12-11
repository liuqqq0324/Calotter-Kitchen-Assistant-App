package org.dromara.system.domain.bo;

import java.util.LinkedHashMap;
import java.util.Map;
import javax.annotation.processing.Generated;
import org.dromara.system.domain.SysSocial;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
<<<<<<< HEAD
    date = "2025-12-10T15:10:35+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
=======
    date = "2025-12-10T13:27:22+1300",
    comments = "version: 1.6.3, compiler: javac, environment: Java 25.0.1 (Homebrew)"
>>>>>>> chase/flutter-v1-android-java
)
@Component
public class SysSocialBoToSysSocialMapperImpl implements SysSocialBoToSysSocialMapper {

    @Override
    public SysSocial convert(SysSocialBo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        SysSocial sysSocial = new SysSocial();

        sysSocial.setSearchValue( arg0.getSearchValue() );
        sysSocial.setCreateDept( arg0.getCreateDept() );
        sysSocial.setCreateBy( arg0.getCreateBy() );
        sysSocial.setCreateTime( arg0.getCreateTime() );
        sysSocial.setUpdateBy( arg0.getUpdateBy() );
        sysSocial.setUpdateTime( arg0.getUpdateTime() );
        Map<String, Object> map = arg0.getParams();
        if ( map != null ) {
            sysSocial.setParams( new LinkedHashMap<String, Object>( map ) );
        }
        sysSocial.setTenantId( arg0.getTenantId() );
        sysSocial.setId( arg0.getId() );
        sysSocial.setUserId( arg0.getUserId() );
        sysSocial.setAuthId( arg0.getAuthId() );
        sysSocial.setSource( arg0.getSource() );
        sysSocial.setAccessToken( arg0.getAccessToken() );
        sysSocial.setExpireIn( arg0.getExpireIn() );
        sysSocial.setRefreshToken( arg0.getRefreshToken() );
        sysSocial.setOpenId( arg0.getOpenId() );
        sysSocial.setUserName( arg0.getUserName() );
        sysSocial.setNickName( arg0.getNickName() );
        sysSocial.setEmail( arg0.getEmail() );
        sysSocial.setAvatar( arg0.getAvatar() );
        sysSocial.setAccessCode( arg0.getAccessCode() );
        sysSocial.setUnionId( arg0.getUnionId() );
        sysSocial.setScope( arg0.getScope() );
        sysSocial.setTokenType( arg0.getTokenType() );
        sysSocial.setIdToken( arg0.getIdToken() );
        sysSocial.setMacAlgorithm( arg0.getMacAlgorithm() );
        sysSocial.setMacKey( arg0.getMacKey() );
        sysSocial.setCode( arg0.getCode() );
        sysSocial.setOauthToken( arg0.getOauthToken() );
        sysSocial.setOauthTokenSecret( arg0.getOauthTokenSecret() );

        return sysSocial;
    }

    @Override
    public SysSocial convert(SysSocialBo arg0, SysSocial arg1) {
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
        arg1.setTenantId( arg0.getTenantId() );
        arg1.setId( arg0.getId() );
        arg1.setUserId( arg0.getUserId() );
        arg1.setAuthId( arg0.getAuthId() );
        arg1.setSource( arg0.getSource() );
        arg1.setAccessToken( arg0.getAccessToken() );
        arg1.setExpireIn( arg0.getExpireIn() );
        arg1.setRefreshToken( arg0.getRefreshToken() );
        arg1.setOpenId( arg0.getOpenId() );
        arg1.setUserName( arg0.getUserName() );
        arg1.setNickName( arg0.getNickName() );
        arg1.setEmail( arg0.getEmail() );
        arg1.setAvatar( arg0.getAvatar() );
        arg1.setAccessCode( arg0.getAccessCode() );
        arg1.setUnionId( arg0.getUnionId() );
        arg1.setScope( arg0.getScope() );
        arg1.setTokenType( arg0.getTokenType() );
        arg1.setIdToken( arg0.getIdToken() );
        arg1.setMacAlgorithm( arg0.getMacAlgorithm() );
        arg1.setMacKey( arg0.getMacKey() );
        arg1.setCode( arg0.getCode() );
        arg1.setOauthToken( arg0.getOauthToken() );
        arg1.setOauthTokenSecret( arg0.getOauthTokenSecret() );

        return arg1;
    }
}
