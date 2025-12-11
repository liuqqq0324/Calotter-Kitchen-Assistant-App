package com.calotter.user.domain.bo;

import com.calotter.user.domain.RoleRestriction;
import java.util.LinkedHashMap;
import java.util.Map;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T17:42:11+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class RoleRestrictionBoToRoleRestrictionMapperImpl implements RoleRestrictionBoToRoleRestrictionMapper {

    @Override
    public RoleRestriction convert(RoleRestrictionBo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        RoleRestriction roleRestriction = new RoleRestriction();

        roleRestriction.setCreateBy( arg0.getCreateBy() );
        roleRestriction.setCreateDept( arg0.getCreateDept() );
        roleRestriction.setCreateTime( arg0.getCreateTime() );
        Map<String, Object> map = arg0.getParams();
        if ( map != null ) {
            roleRestriction.setParams( new LinkedHashMap<String, Object>( map ) );
        }
        roleRestriction.setSearchValue( arg0.getSearchValue() );
        roleRestriction.setUpdateBy( arg0.getUpdateBy() );
        roleRestriction.setUpdateTime( arg0.getUpdateTime() );
        roleRestriction.setId( arg0.getId() );
        roleRestriction.setRestrictionId( arg0.getRestrictionId() );
        roleRestriction.setRoleId( arg0.getRoleId() );
        roleRestriction.setType( arg0.getType() );

        return roleRestriction;
    }

    @Override
    public RoleRestriction convert(RoleRestrictionBo arg0, RoleRestriction arg1) {
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
        arg1.setId( arg0.getId() );
        arg1.setRestrictionId( arg0.getRestrictionId() );
        arg1.setRoleId( arg0.getRoleId() );
        arg1.setType( arg0.getType() );

        return arg1;
    }
}
