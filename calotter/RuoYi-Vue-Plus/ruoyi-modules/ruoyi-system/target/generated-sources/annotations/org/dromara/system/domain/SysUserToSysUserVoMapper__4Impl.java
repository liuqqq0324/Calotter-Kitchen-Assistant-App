package org.dromara.system.domain;

import javax.annotation.processing.Generated;
import org.dromara.system.domain.vo.SysUserVo;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-10T12:23:16+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class SysUserToSysUserVoMapper__4Impl implements SysUserToSysUserVoMapper__4 {

    @Override
    public SysUserVo convert(SysUser arg0) {
        if ( arg0 == null ) {
            return null;
        }

        SysUserVo sysUserVo = new SysUserVo();

        sysUserVo.setAvatar( arg0.getAvatar() );
        sysUserVo.setCreateTime( arg0.getCreateTime() );
        sysUserVo.setDeptId( arg0.getDeptId() );
        sysUserVo.setEmail( arg0.getEmail() );
        sysUserVo.setLoginDate( arg0.getLoginDate() );
        sysUserVo.setLoginIp( arg0.getLoginIp() );
        sysUserVo.setNickName( arg0.getNickName() );
        sysUserVo.setPassword( arg0.getPassword() );
        sysUserVo.setPhonenumber( arg0.getPhonenumber() );
        sysUserVo.setRemark( arg0.getRemark() );
        sysUserVo.setSex( arg0.getSex() );
        sysUserVo.setStatus( arg0.getStatus() );
        sysUserVo.setTenantId( arg0.getTenantId() );
        sysUserVo.setUserId( arg0.getUserId() );
        sysUserVo.setUserName( arg0.getUserName() );
        sysUserVo.setUserType( arg0.getUserType() );

        return sysUserVo;
    }

    @Override
    public SysUserVo convert(SysUser arg0, SysUserVo arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setAvatar( arg0.getAvatar() );
        arg1.setCreateTime( arg0.getCreateTime() );
        arg1.setDeptId( arg0.getDeptId() );
        arg1.setEmail( arg0.getEmail() );
        arg1.setLoginDate( arg0.getLoginDate() );
        arg1.setLoginIp( arg0.getLoginIp() );
        arg1.setNickName( arg0.getNickName() );
        arg1.setPassword( arg0.getPassword() );
        arg1.setPhonenumber( arg0.getPhonenumber() );
        arg1.setRemark( arg0.getRemark() );
        arg1.setSex( arg0.getSex() );
        arg1.setStatus( arg0.getStatus() );
        arg1.setTenantId( arg0.getTenantId() );
        arg1.setUserId( arg0.getUserId() );
        arg1.setUserName( arg0.getUserName() );
        arg1.setUserType( arg0.getUserType() );

        return arg1;
    }
}
