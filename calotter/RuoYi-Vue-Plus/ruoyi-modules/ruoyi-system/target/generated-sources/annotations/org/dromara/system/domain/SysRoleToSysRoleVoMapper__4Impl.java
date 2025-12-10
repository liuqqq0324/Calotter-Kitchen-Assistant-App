package org.dromara.system.domain;

import javax.annotation.processing.Generated;
import org.dromara.system.domain.vo.SysRoleVo;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-10T15:10:33+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class SysRoleToSysRoleVoMapper__4Impl implements SysRoleToSysRoleVoMapper__4 {

    @Override
    public SysRoleVo convert(SysRole arg0) {
        if ( arg0 == null ) {
            return null;
        }

        SysRoleVo sysRoleVo = new SysRoleVo();

        sysRoleVo.setCreateTime( arg0.getCreateTime() );
        sysRoleVo.setDataScope( arg0.getDataScope() );
        sysRoleVo.setDeptCheckStrictly( arg0.getDeptCheckStrictly() );
        sysRoleVo.setMenuCheckStrictly( arg0.getMenuCheckStrictly() );
        sysRoleVo.setRemark( arg0.getRemark() );
        sysRoleVo.setRoleId( arg0.getRoleId() );
        sysRoleVo.setRoleKey( arg0.getRoleKey() );
        sysRoleVo.setRoleName( arg0.getRoleName() );
        sysRoleVo.setRoleSort( arg0.getRoleSort() );
        sysRoleVo.setStatus( arg0.getStatus() );

        return sysRoleVo;
    }

    @Override
    public SysRoleVo convert(SysRole arg0, SysRoleVo arg1) {
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
