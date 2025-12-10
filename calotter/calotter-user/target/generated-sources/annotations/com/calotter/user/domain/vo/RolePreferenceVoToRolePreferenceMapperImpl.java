package com.calotter.user.domain.vo;

import com.calotter.user.domain.RolePreference;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-10T15:10:17+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class RolePreferenceVoToRolePreferenceMapperImpl implements RolePreferenceVoToRolePreferenceMapper {

    @Override
    public RolePreference convert(RolePreferenceVo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        RolePreference rolePreference = new RolePreference();

        rolePreference.setId( arg0.getId() );
        rolePreference.setLevel( arg0.getLevel() );
        rolePreference.setPreferenceId( arg0.getPreferenceId() );
        rolePreference.setRoleId( arg0.getRoleId() );

        return rolePreference;
    }

    @Override
    public RolePreference convert(RolePreferenceVo arg0, RolePreference arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setId( arg0.getId() );
        arg1.setLevel( arg0.getLevel() );
        arg1.setPreferenceId( arg0.getPreferenceId() );
        arg1.setRoleId( arg0.getRoleId() );

        return arg1;
    }
}
