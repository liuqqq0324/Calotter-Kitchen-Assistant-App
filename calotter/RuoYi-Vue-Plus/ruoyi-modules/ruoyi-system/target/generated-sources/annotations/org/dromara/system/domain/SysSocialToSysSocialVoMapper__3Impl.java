package org.dromara.system.domain;

import javax.annotation.processing.Generated;
import org.dromara.system.domain.vo.SysSocialVo;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T11:30:24+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class SysSocialToSysSocialVoMapper__3Impl implements SysSocialToSysSocialVoMapper__3 {

    @Override
    public SysSocialVo convert(SysSocial arg0) {
        if ( arg0 == null ) {
            return null;
        }

        SysSocialVo sysSocialVo = new SysSocialVo();

        sysSocialVo.setAccessCode( arg0.getAccessCode() );
        sysSocialVo.setAccessToken( arg0.getAccessToken() );
        sysSocialVo.setAuthId( arg0.getAuthId() );
        sysSocialVo.setAvatar( arg0.getAvatar() );
        sysSocialVo.setCode( arg0.getCode() );
        sysSocialVo.setCreateTime( arg0.getCreateTime() );
        sysSocialVo.setEmail( arg0.getEmail() );
        sysSocialVo.setExpireIn( arg0.getExpireIn() );
        sysSocialVo.setId( arg0.getId() );
        sysSocialVo.setIdToken( arg0.getIdToken() );
        sysSocialVo.setMacAlgorithm( arg0.getMacAlgorithm() );
        sysSocialVo.setMacKey( arg0.getMacKey() );
        sysSocialVo.setNickName( arg0.getNickName() );
        sysSocialVo.setOauthToken( arg0.getOauthToken() );
        sysSocialVo.setOauthTokenSecret( arg0.getOauthTokenSecret() );
        sysSocialVo.setOpenId( arg0.getOpenId() );
        sysSocialVo.setRefreshToken( arg0.getRefreshToken() );
        sysSocialVo.setScope( arg0.getScope() );
        sysSocialVo.setSource( arg0.getSource() );
        sysSocialVo.setTenantId( arg0.getTenantId() );
        sysSocialVo.setTokenType( arg0.getTokenType() );
        sysSocialVo.setUnionId( arg0.getUnionId() );
        sysSocialVo.setUserId( arg0.getUserId() );
        sysSocialVo.setUserName( arg0.getUserName() );

        return sysSocialVo;
    }

    @Override
    public SysSocialVo convert(SysSocial arg0, SysSocialVo arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setAccessCode( arg0.getAccessCode() );
        arg1.setAccessToken( arg0.getAccessToken() );
        arg1.setAuthId( arg0.getAuthId() );
        arg1.setAvatar( arg0.getAvatar() );
        arg1.setCode( arg0.getCode() );
        arg1.setCreateTime( arg0.getCreateTime() );
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
        arg1.setTenantId( arg0.getTenantId() );
        arg1.setTokenType( arg0.getTokenType() );
        arg1.setUnionId( arg0.getUnionId() );
        arg1.setUserId( arg0.getUserId() );
        arg1.setUserName( arg0.getUserName() );

        return arg1;
    }
}
