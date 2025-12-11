package com.calotter.user.domain.vo;

import com.calotter.user.domain.RolePreference;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T14:28:56+1300",
    comments = "version: 1.6.3, compiler: javac, environment: Java 21.0.8 (JetBrains s.r.o.)"
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
        rolePreference.setRoleId( arg0.getRoleId() );
        rolePreference.setPreferenceId( arg0.getPreferenceId() );
        rolePreference.setLevel( arg0.getLevel() );

        return rolePreference;
    }

    @Override
    public RolePreference convert(RolePreferenceVo arg0, RolePreference arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setId( arg0.getId() );
        arg1.setRoleId( arg0.getRoleId() );
        arg1.setPreferenceId( arg0.getPreferenceId() );
        arg1.setLevel( arg0.getLevel() );

        return arg1;
    }
}
