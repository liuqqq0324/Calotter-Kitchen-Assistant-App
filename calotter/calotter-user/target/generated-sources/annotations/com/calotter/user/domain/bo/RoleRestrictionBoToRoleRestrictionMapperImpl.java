package com.calotter.user.domain.bo;

import com.calotter.user.domain.RoleRestriction;
import java.util.LinkedHashMap;
import java.util.Map;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T14:28:56+1300",
    comments = "version: 1.6.3, compiler: javac, environment: Java 21.0.8 (JetBrains s.r.o.)"
)
@Component
public class RoleRestrictionBoToRoleRestrictionMapperImpl implements RoleRestrictionBoToRoleRestrictionMapper {

    @Override
    public RoleRestriction convert(RoleRestrictionBo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        RoleRestriction roleRestriction = new RoleRestriction();

        roleRestriction.setSearchValue( arg0.getSearchValue() );
        roleRestriction.setCreateDept( arg0.getCreateDept() );
        roleRestriction.setCreateBy( arg0.getCreateBy() );
        roleRestriction.setCreateTime( arg0.getCreateTime() );
        roleRestriction.setUpdateBy( arg0.getUpdateBy() );
        roleRestriction.setUpdateTime( arg0.getUpdateTime() );
        Map<String, Object> map = arg0.getParams();
        if ( map != null ) {
            roleRestriction.setParams( new LinkedHashMap<String, Object>( map ) );
        }
        roleRestriction.setId( arg0.getId() );
        roleRestriction.setRoleId( arg0.getRoleId() );
        roleRestriction.setRestrictionId( arg0.getRestrictionId() );
        roleRestriction.setType( arg0.getType() );

        return roleRestriction;
    }

    @Override
    public RoleRestriction convert(RoleRestrictionBo arg0, RoleRestriction arg1) {
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
        arg1.setId( arg0.getId() );
        arg1.setRoleId( arg0.getRoleId() );
        arg1.setRestrictionId( arg0.getRestrictionId() );
        arg1.setType( arg0.getType() );

        return arg1;
    }
}
