package org.dromara.system.domain;

import javax.annotation.processing.Generated;
import org.dromara.system.domain.vo.SysRoleVo;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-10T12:23:26+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class SysRoleToSysRoleVoMapper__14Impl implements SysRoleToSysRoleVoMapper__14 {

    @Override
    public SysRoleVo convert(SysRole arg0) {
        if ( arg0 == null ) {
            return null;
        }

        SysRoleVo sysRoleVo = new SysRoleVo();

        sysRoleVo.setRoleId( arg0.getRoleId() );
        sysRoleVo.setRoleName( arg0.getRoleName() );
        sysRoleVo.setRoleKey( arg0.getRoleKey() );
        sysRoleVo.setRoleSort( arg0.getRoleSort() );
        sysRoleVo.setDataScope( arg0.getDataScope() );
        sysRoleVo.setMenuCheckStrictly( arg0.getMenuCheckStrictly() );
        sysRoleVo.setDeptCheckStrictly( arg0.getDeptCheckStrictly() );
        sysRoleVo.setStatus( arg0.getStatus() );
        sysRoleVo.setRemark( arg0.getRemark() );
        sysRoleVo.setCreateTime( arg0.getCreateTime() );

        return sysRoleVo;
    }

    @Override
    public SysRoleVo convert(SysRole arg0, SysRoleVo arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setRoleId( arg0.getRoleId() );
        arg1.setRoleName( arg0.getRoleName() );
        arg1.setRoleKey( arg0.getRoleKey() );
        arg1.setRoleSort( arg0.getRoleSort() );
        arg1.setDataScope( arg0.getDataScope() );
        arg1.setMenuCheckStrictly( arg0.getMenuCheckStrictly() );
        arg1.setDeptCheckStrictly( arg0.getDeptCheckStrictly() );
        arg1.setStatus( arg0.getStatus() );
        arg1.setRemark( arg0.getRemark() );
        arg1.setCreateTime( arg0.getCreateTime() );

        return arg1;
    }
}
