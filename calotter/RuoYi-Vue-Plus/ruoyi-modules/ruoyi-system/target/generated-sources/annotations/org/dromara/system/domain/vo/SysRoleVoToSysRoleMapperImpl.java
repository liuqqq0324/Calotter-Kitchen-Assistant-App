package org.dromara.system.domain.vo;

import javax.annotation.processing.Generated;
import org.dromara.system.domain.SysRole;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
<<<<<<< HEAD
    date = "2025-12-10T15:10:36+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
=======
    date = "2025-12-10T13:27:22+1300",
    comments = "version: 1.6.3, compiler: javac, environment: Java 25.0.1 (Homebrew)"
>>>>>>> chase/flutter-v1-android-java
)
@Component
public class SysRoleVoToSysRoleMapperImpl implements SysRoleVoToSysRoleMapper {

    @Override
    public SysRole convert(SysRoleVo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        SysRole sysRole = new SysRole();

        sysRole.setCreateTime( arg0.getCreateTime() );
        sysRole.setRoleId( arg0.getRoleId() );
        sysRole.setRoleName( arg0.getRoleName() );
        sysRole.setRoleKey( arg0.getRoleKey() );
        sysRole.setRoleSort( arg0.getRoleSort() );
        sysRole.setDataScope( arg0.getDataScope() );
        sysRole.setMenuCheckStrictly( arg0.getMenuCheckStrictly() );
        sysRole.setDeptCheckStrictly( arg0.getDeptCheckStrictly() );
        sysRole.setStatus( arg0.getStatus() );
        sysRole.setRemark( arg0.getRemark() );

        return sysRole;
    }

    @Override
    public SysRole convert(SysRoleVo arg0, SysRole arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setCreateTime( arg0.getCreateTime() );
        arg1.setRoleId( arg0.getRoleId() );
        arg1.setRoleName( arg0.getRoleName() );
        arg1.setRoleKey( arg0.getRoleKey() );
        arg1.setRoleSort( arg0.getRoleSort() );
        arg1.setDataScope( arg0.getDataScope() );
        arg1.setMenuCheckStrictly( arg0.getMenuCheckStrictly() );
        arg1.setDeptCheckStrictly( arg0.getDeptCheckStrictly() );
        arg1.setStatus( arg0.getStatus() );
        arg1.setRemark( arg0.getRemark() );

        return arg1;
    }
}
