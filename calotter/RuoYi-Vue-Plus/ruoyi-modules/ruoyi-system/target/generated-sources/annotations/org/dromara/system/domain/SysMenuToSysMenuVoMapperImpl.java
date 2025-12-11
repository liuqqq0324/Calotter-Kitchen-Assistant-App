package org.dromara.system.domain;

import java.util.List;
import javax.annotation.processing.Generated;
import org.dromara.system.domain.vo.SysMenuVo;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T17:59:10+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
public class SysMenuToSysMenuVoMapperImpl implements SysMenuToSysMenuVoMapper {

    @Override
    public SysMenuVo convert(SysMenu arg0) {
        if ( arg0 == null ) {
            return null;
        }

        SysMenuVo sysMenuVo = new SysMenuVo();

        sysMenuVo.setMenuId( arg0.getMenuId() );
        sysMenuVo.setMenuName( arg0.getMenuName() );
        sysMenuVo.setParentId( arg0.getParentId() );
        sysMenuVo.setOrderNum( arg0.getOrderNum() );
        sysMenuVo.setPath( arg0.getPath() );
        sysMenuVo.setComponent( arg0.getComponent() );
        sysMenuVo.setQueryParam( arg0.getQueryParam() );
        sysMenuVo.setIsFrame( arg0.getIsFrame() );
        sysMenuVo.setIsCache( arg0.getIsCache() );
        sysMenuVo.setMenuType( arg0.getMenuType() );
        sysMenuVo.setVisible( arg0.getVisible() );
        sysMenuVo.setStatus( arg0.getStatus() );
        sysMenuVo.setPerms( arg0.getPerms() );
        sysMenuVo.setIcon( arg0.getIcon() );
        sysMenuVo.setCreateDept( arg0.getCreateDept() );
        sysMenuVo.setRemark( arg0.getRemark() );
        sysMenuVo.setCreateTime( arg0.getCreateTime() );
        sysMenuVo.setChildren( convert( arg0.getChildren() ) );

        return sysMenuVo;
    }

    @Override
    public SysMenuVo convert(SysMenu arg0, SysMenuVo arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setMenuId( arg0.getMenuId() );
        arg1.setMenuName( arg0.getMenuName() );
        arg1.setParentId( arg0.getParentId() );
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
        arg1.setCreateDept( arg0.getCreateDept() );
        arg1.setRemark( arg0.getRemark() );
        arg1.setCreateTime( arg0.getCreateTime() );
        if ( arg1.getChildren() != null ) {
            List<SysMenuVo> list = convert( arg0.getChildren() );
            if ( list != null ) {
                arg1.getChildren().clear();
                arg1.getChildren().addAll( list );
            }
            else {
                arg1.setChildren( null );
            }
        }
        else {
            List<SysMenuVo> list = convert( arg0.getChildren() );
            if ( list != null ) {
                arg1.setChildren( list );
            }
        }

        return arg1;
    }
}
