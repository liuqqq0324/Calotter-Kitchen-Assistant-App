package org.dromara.system.domain.vo;

import javax.annotation.processing.Generated;
import org.dromara.system.domain.SysUser;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T17:59:11+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
public class SysUserVoToSysUserMapperImpl implements SysUserVoToSysUserMapper {

    @Override
    public SysUser convert(SysUserVo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        SysUser sysUser = new SysUser();

        sysUser.setCreateTime( arg0.getCreateTime() );
        sysUser.setTenantId( arg0.getTenantId() );
        sysUser.setUserId( arg0.getUserId() );
        sysUser.setDeptId( arg0.getDeptId() );
        sysUser.setUserName( arg0.getUserName() );
        sysUser.setNickName( arg0.getNickName() );
        sysUser.setUserType( arg0.getUserType() );
        sysUser.setEmail( arg0.getEmail() );
        sysUser.setPhonenumber( arg0.getPhonenumber() );
        sysUser.setSex( arg0.getSex() );
        sysUser.setAvatar( arg0.getAvatar() );
        sysUser.setPassword( arg0.getPassword() );
        sysUser.setStatus( arg0.getStatus() );
        sysUser.setLoginIp( arg0.getLoginIp() );
        sysUser.setLoginDate( arg0.getLoginDate() );
        sysUser.setRemark( arg0.getRemark() );

        return sysUser;
    }

    @Override
    public SysUser convert(SysUserVo arg0, SysUser arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setCreateTime( arg0.getCreateTime() );
        arg1.setTenantId( arg0.getTenantId() );
        arg1.setUserId( arg0.getUserId() );
        arg1.setDeptId( arg0.getDeptId() );
        arg1.setUserName( arg0.getUserName() );
        arg1.setNickName( arg0.getNickName() );
        arg1.setUserType( arg0.getUserType() );
        arg1.setEmail( arg0.getEmail() );
        arg1.setPhonenumber( arg0.getPhonenumber() );
        arg1.setSex( arg0.getSex() );
        arg1.setAvatar( arg0.getAvatar() );
        arg1.setPassword( arg0.getPassword() );
        arg1.setStatus( arg0.getStatus() );
        arg1.setLoginIp( arg0.getLoginIp() );
        arg1.setLoginDate( arg0.getLoginDate() );
        arg1.setRemark( arg0.getRemark() );

        return arg1;
    }
}
