package com.calotter.user.domain.vo;

import com.calotter.user.domain.RoleRestriction;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T14:28:56+1300",
    comments = "version: 1.6.3, compiler: javac, environment: Java 21.0.8 (JetBrains s.r.o.)"
)
@Component
public class RoleRestrictionVoToRoleRestrictionMapperImpl implements RoleRestrictionVoToRoleRestrictionMapper {

    @Override
    public RoleRestriction convert(RoleRestrictionVo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        RoleRestriction roleRestriction = new RoleRestriction();

        roleRestriction.setId( arg0.getId() );
        roleRestriction.setRoleId( arg0.getRoleId() );
        roleRestriction.setRestrictionId( arg0.getRestrictionId() );
        roleRestriction.setType( arg0.getType() );

        return roleRestriction;
    }

    @Override
    public RoleRestriction convert(RoleRestrictionVo arg0, RoleRestriction arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setId( arg0.getId() );
        arg1.setRoleId( arg0.getRoleId() );
        arg1.setRestrictionId( arg0.getRestrictionId() );
        arg1.setType( arg0.getType() );

        return arg1;
    }
}
