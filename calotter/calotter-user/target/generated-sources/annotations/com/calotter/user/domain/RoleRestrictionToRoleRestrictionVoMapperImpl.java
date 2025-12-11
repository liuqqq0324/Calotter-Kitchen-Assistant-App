package com.calotter.user.domain;

import com.calotter.user.domain.vo.RoleRestrictionVo;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T17:42:11+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class RoleRestrictionToRoleRestrictionVoMapperImpl implements RoleRestrictionToRoleRestrictionVoMapper {

    @Override
    public RoleRestrictionVo convert(RoleRestriction arg0) {
        if ( arg0 == null ) {
            return null;
        }

        RoleRestrictionVo roleRestrictionVo = new RoleRestrictionVo();

        roleRestrictionVo.setId( arg0.getId() );
        roleRestrictionVo.setRestrictionId( arg0.getRestrictionId() );
        roleRestrictionVo.setRoleId( arg0.getRoleId() );
        roleRestrictionVo.setType( arg0.getType() );

        return roleRestrictionVo;
    }

    @Override
    public RoleRestrictionVo convert(RoleRestriction arg0, RoleRestrictionVo arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setId( arg0.getId() );
        arg1.setRestrictionId( arg0.getRestrictionId() );
        arg1.setRoleId( arg0.getRoleId() );
        arg1.setType( arg0.getType() );

        return arg1;
    }
}
