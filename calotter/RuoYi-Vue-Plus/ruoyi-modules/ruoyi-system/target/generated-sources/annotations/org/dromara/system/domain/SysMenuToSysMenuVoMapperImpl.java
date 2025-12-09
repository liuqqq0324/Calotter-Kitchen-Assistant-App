package org.dromara.system.domain;

import java.util.List;
import javax.annotation.processing.Generated;
import org.dromara.system.domain.vo.SysMenuVo;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-10T12:08:12+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class SysMenuToSysMenuVoMapperImpl implements SysMenuToSysMenuVoMapper {

    @Override
    public SysMenuVo convert(SysMenu arg0) {
        if ( arg0 == null ) {
            return null;
        }

        SysMenuVo sysMenuVo = new SysMenuVo();

        sysMenuVo.setChildren( convert( arg0.getChildren() ) );
        sysMenuVo.setComponent( arg0.getComponent() );
        sysMenuVo.setCreateDept( arg0.getCreateDept() );
        sysMenuVo.setCreateTime( arg0.getCreateTime() );
        sysMenuVo.setIcon( arg0.getIcon() );
        sysMenuVo.setIsCache( arg0.getIsCache() );
        sysMenuVo.setIsFrame( arg0.getIsFrame() );
        sysMenuVo.setMenuId( arg0.getMenuId() );
        sysMenuVo.setMenuName( arg0.getMenuName() );
        sysMenuVo.setMenuType( arg0.getMenuType() );
        sysMenuVo.setOrderNum( arg0.getOrderNum() );
        sysMenuVo.setParentId( arg0.getParentId() );
        sysMenuVo.setPath( arg0.getPath() );
        sysMenuVo.setPerms( arg0.getPerms() );
        sysMenuVo.setQueryParam( arg0.getQueryParam() );
        sysMenuVo.setRemark( arg0.getRemark() );
        sysMenuVo.setStatus( arg0.getStatus() );
        sysMenuVo.setVisible( arg0.getVisible() );

        return sysMenuVo;
    }

    @Override
    public SysMenuVo convert(SysMenu arg0, SysMenuVo arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

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
        arg1.setComponent( arg0.getComponent() );
        arg1.setCreateDept( arg0.getCreateDept() );
        arg1.setCreateTime( arg0.getCreateTime() );
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
