package org.dromara.system.domain.vo;

import javax.annotation.processing.Generated;
import org.dromara.system.domain.SysSocial;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T13:58:03+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class SysSocialVoToSysSocialMapper__1Impl implements SysSocialVoToSysSocialMapper__1 {

    @Override
    public SysSocial convert(SysSocialVo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        SysSocial sysSocial = new SysSocial();

        sysSocial.setCreateTime( arg0.getCreateTime() );
        sysSocial.setTenantId( arg0.getTenantId() );
        sysSocial.setAccessCode( arg0.getAccessCode() );
        sysSocial.setAccessToken( arg0.getAccessToken() );
        sysSocial.setAuthId( arg0.getAuthId() );
        sysSocial.setAvatar( arg0.getAvatar() );
        sysSocial.setCode( arg0.getCode() );
        sysSocial.setEmail( arg0.getEmail() );
        sysSocial.setExpireIn( arg0.getExpireIn() );
        sysSocial.setId( arg0.getId() );
        sysSocial.setIdToken( arg0.getIdToken() );
        sysSocial.setMacAlgorithm( arg0.getMacAlgorithm() );
        sysSocial.setMacKey( arg0.getMacKey() );
        sysSocial.setNickName( arg0.getNickName() );
        sysSocial.setOauthToken( arg0.getOauthToken() );
        sysSocial.setOauthTokenSecret( arg0.getOauthTokenSecret() );
        sysSocial.setOpenId( arg0.getOpenId() );
        sysSocial.setRefreshToken( arg0.getRefreshToken() );
        sysSocial.setScope( arg0.getScope() );
        sysSocial.setSource( arg0.getSource() );
        sysSocial.setTokenType( arg0.getTokenType() );
        sysSocial.setUnionId( arg0.getUnionId() );
        sysSocial.setUserId( arg0.getUserId() );
        sysSocial.setUserName( arg0.getUserName() );

        return sysSocial;
    }

    @Override
    public SysSocial convert(SysSocialVo arg0, SysSocial arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setCreateTime( arg0.getCreateTime() );
        arg1.setTenantId( arg0.getTenantId() );
        arg1.setAccessCode( arg0.getAccessCode() );
        arg1.setAccessToken( arg0.getAccessToken() );
        arg1.setAuthId( arg0.getAuthId() );
        arg1.setAvatar( arg0.getAvatar() );
        arg1.setCode( arg0.getCode() );
        arg1.setEmail( arg0.getEmail() );
        arg1.setExpireIn( arg0.getExpireIn() );
        arg1.setId( arg0.getId() );
        arg1.setIdToken( arg0.getIdToken() );
        arg1.setMacAlgorithm( arg0.getMacAlgorithm() );
        arg1.setMacKey( arg0.getMacKey() );
        arg1.setNickName( arg0.getNickName() );
        arg1.setOauthToken( arg0.getOauthToken() );
        arg1.setOauthTokenSecret( arg0.getOauthTokenSecret() );
        arg1.setOpenId( arg0.getOpenId() );
        arg1.setRefreshToken( arg0.getRefreshToken() );
        arg1.setScope( arg0.getScope() );
        arg1.setSource( arg0.getSource() );
        arg1.setTokenType( arg0.getTokenType() );
        arg1.setUnionId( arg0.getUnionId() );
        arg1.setUserId( arg0.getUserId() );
        arg1.setUserName( arg0.getUserName() );

        return arg1;
    }
}
