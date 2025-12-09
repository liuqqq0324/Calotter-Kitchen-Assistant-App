package org.dromara.system.domain.bo;

import java.util.LinkedHashMap;
import java.util.Map;
import javax.annotation.processing.Generated;
import org.dromara.system.domain.SysRole;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-10T12:08:12+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class SysRoleBoToSysRoleMapperImpl implements SysRoleBoToSysRoleMapper {

    @Override
    public SysRole convert(SysRoleBo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        SysRole sysRole = new SysRole();

        sysRole.setCreateBy( arg0.getCreateBy() );
        sysRole.setCreateDept( arg0.getCreateDept() );
        sysRole.setCreateTime( arg0.getCreateTime() );
        Map<String, Object> map = arg0.getParams();
        if ( map != null ) {
            sysRole.setParams( new LinkedHashMap<String, Object>( map ) );
        }
        sysRole.setSearchValue( arg0.getSearchValue() );
        sysRole.setUpdateBy( arg0.getUpdateBy() );
        sysRole.setUpdateTime( arg0.getUpdateTime() );
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
    public SysRole convert(SysRoleBo arg0, SysRole arg1) {
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
