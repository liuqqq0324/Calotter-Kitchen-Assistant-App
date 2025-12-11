package org.dromara.system.domain.vo;

import javax.annotation.processing.Generated;
import org.dromara.system.domain.SysRole;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T13:58:03+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class SysRoleVoToSysRoleMapper__1Impl implements SysRoleVoToSysRoleMapper__1 {

    @Override
    public SysRole convert(SysRoleVo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        SysRole sysRole = new SysRole();

        sysRole.setCreateTime( arg0.getCreateTime() );
        sysRole.setDataScope( arg0.getDataScope() );
        sysRole.setDeptCheckStrictly( arg0.getDeptCheckStrictly() );
        sysRole.setMenuCheckStrictly( arg0.getMenuCheckStrictly() );
        sysRole.setRemark( arg0.getRemark() );
        sysRole.setRoleId( arg0.getRoleId() );
        sysRole.setRoleKey( arg0.getRoleKey() );
        sysRole.setRoleName( arg0.getRoleName() );
        sysRole.setRoleSort( arg0.getRoleSort() );
        sysRole.setStatus( arg0.getStatus() );

        return sysRole;
    }

    @Override
    public SysRole convert(SysRoleVo arg0, SysRole arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setCreateTime( arg0.getCreateTime() );
        arg1.setDataScope( arg0.getDataScope() );
        arg1.setDeptCheckStrictly( arg0.getDeptCheckStrictly() );
        arg1.setMenuCheckStrictly( arg0.getMenuCheckStrictly() );
        arg1.setRemark( arg0.getRemark() );
        arg1.setRoleId( arg0.getRoleId() );
        arg1.setRoleKey( arg0.getRoleKey() );
        arg1.setRoleName( arg0.getRoleName() );
        arg1.setRoleSort( arg0.getRoleSort() );
        arg1.setStatus( arg0.getStatus() );

        return arg1;
    }
}
