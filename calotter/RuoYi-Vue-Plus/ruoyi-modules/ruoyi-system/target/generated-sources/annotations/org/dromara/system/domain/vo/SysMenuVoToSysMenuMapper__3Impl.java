package org.dromara.system.domain.vo;

import java.util.List;
import javax.annotation.processing.Generated;
import org.dromara.system.domain.SysMenu;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T11:30:24+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class SysMenuVoToSysMenuMapper__3Impl implements SysMenuVoToSysMenuMapper__3 {

    @Override
    public SysMenu convert(SysMenuVo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        SysMenu sysMenu = new SysMenu();

        sysMenu.setCreateDept( arg0.getCreateDept() );
        sysMenu.setCreateTime( arg0.getCreateTime() );
        sysMenu.setChildren( convert( arg0.getChildren() ) );
        sysMenu.setComponent( arg0.getComponent() );
        sysMenu.setIcon( arg0.getIcon() );
        sysMenu.setIsCache( arg0.getIsCache() );
        sysMenu.setIsFrame( arg0.getIsFrame() );
        sysMenu.setMenuId( arg0.getMenuId() );
        sysMenu.setMenuName( arg0.getMenuName() );
        sysMenu.setMenuType( arg0.getMenuType() );
        sysMenu.setOrderNum( arg0.getOrderNum() );
        sysMenu.setParentId( arg0.getParentId() );
        sysMenu.setPath( arg0.getPath() );
        sysMenu.setPerms( arg0.getPerms() );
        sysMenu.setQueryParam( arg0.getQueryParam() );
        sysMenu.setRemark( arg0.getRemark() );
        sysMenu.setStatus( arg0.getStatus() );
        sysMenu.setVisible( arg0.getVisible() );

        return sysMenu;
    }

    @Override
    public SysMenu convert(SysMenuVo arg0, SysMenu arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setCreateDept( arg0.getCreateDept() );
        arg1.setCreateTime( arg0.getCreateTime() );
        if ( arg1.getChildren() != null ) {
            List<SysMenu> list = convert( arg0.getChildren() );
            if ( list != null ) {
                arg1.getChildren().clear();
                arg1.getChildren().addAll( list );
            }
            else {
                arg1.setChildren( null );
            }
        }
        else {
            List<SysMenu> list = convert( arg0.getChildren() );
            if ( list != null ) {
                arg1.setChildren( list );
            }
        }
        arg1.setComponent( arg0.getComponent() );
        arg1.setIcon( arg0.getIcon() );
        arg1.setIsCache( arg0.getIsCache() );
        arg1.setIsFrame( arg0.getIsFrame() );
        arg1.setMenuId( arg0.getMenuId() );
        arg1.setMenuName( arg0.getMenuName() );
        arg1.setMenuType( arg0.getMenuType() );
        arg1.setOrderNum( arg0.getOrderNum() );
        arg1.setParentId( arg0.getParentId() );
        arg1.setPath( arg0.getPath() );
        arg1.setPerms( arg0.getPerms() );
        arg1.setQueryParam( arg0.getQueryParam() );
        arg1.setRemark( arg0.getRemark() );
        arg1.setStatus( arg0.getStatus() );
        arg1.setVisible( arg0.getVisible() );

        return arg1;
    }
}
