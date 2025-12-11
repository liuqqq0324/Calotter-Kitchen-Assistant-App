package org.dromara.system.domain.bo;

import java.util.LinkedHashMap;
import java.util.Map;
import javax.annotation.processing.Generated;
import org.dromara.system.domain.SysMenu;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T16:49:58+1300",
    comments = "version: 1.6.3, compiler: javac, environment: Java 25.0.1 (Homebrew)"
)
@Component
public class SysMenuBoToSysMenuMapperImpl implements SysMenuBoToSysMenuMapper {

    @Override
    public SysMenu convert(SysMenuBo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        SysMenu sysMenu = new SysMenu();

        sysMenu.setSearchValue( arg0.getSearchValue() );
        sysMenu.setCreateDept( arg0.getCreateDept() );
        sysMenu.setCreateBy( arg0.getCreateBy() );
        sysMenu.setCreateTime( arg0.getCreateTime() );
        sysMenu.setUpdateBy( arg0.getUpdateBy() );
        sysMenu.setUpdateTime( arg0.getUpdateTime() );
        Map<String, Object> map = arg0.getParams();
        if ( map != null ) {
            sysMenu.setParams( new LinkedHashMap<String, Object>( map ) );
        }
        sysMenu.setMenuId( arg0.getMenuId() );
        sysMenu.setParentId( arg0.getParentId() );
        sysMenu.setMenuName( arg0.getMenuName() );
        sysMenu.setOrderNum( arg0.getOrderNum() );
        sysMenu.setPath( arg0.getPath() );
        sysMenu.setComponent( arg0.getComponent() );
        sysMenu.setQueryParam( arg0.getQueryParam() );
        sysMenu.setIsFrame( arg0.getIsFrame() );
        sysMenu.setIsCache( arg0.getIsCache() );
        sysMenu.setMenuType( arg0.getMenuType() );
        sysMenu.setVisible( arg0.getVisible() );
        sysMenu.setStatus( arg0.getStatus() );
        sysMenu.setPerms( arg0.getPerms() );
        sysMenu.setIcon( arg0.getIcon() );
        sysMenu.setRemark( arg0.getRemark() );

        return sysMenu;
    }

    @Override
    public SysMenu convert(SysMenuBo arg0, SysMenu arg1) {
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
        arg1.setMenuId( arg0.getMenuId() );
        arg1.setParentId( arg0.getParentId() );
        arg1.setMenuName( arg0.getMenuName() );
        arg1.setOrderNum( arg0.getOrderNum() );
        arg1.setPath( arg0.getPath() );
        arg1.setComponent( arg0.getComponent() );
        arg1.setQueryParam( arg0.getQueryParam() );
        arg1.setIsFrame( arg0.getIsFrame() );
        arg1.setIsCache( arg0.getIsCache() );
        arg1.setMenuType( arg0.getMenuType() );
        arg1.setVisible( arg0.getVisible() );
        arg1.setStatus( arg0.getStatus() );
        arg1.setPerms( arg0.getPerms() );
        arg1.setIcon( arg0.getIcon() );
        arg1.setRemark( arg0.getRemark() );

        return arg1;
    }
}
