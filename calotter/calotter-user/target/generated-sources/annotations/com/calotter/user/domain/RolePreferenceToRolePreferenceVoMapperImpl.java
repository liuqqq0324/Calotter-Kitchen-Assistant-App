package com.calotter.user.domain;

import com.calotter.user.domain.vo.RolePreferenceVo;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T14:28:56+1300",
    comments = "version: 1.6.3, compiler: javac, environment: Java 21.0.8 (JetBrains s.r.o.)"
)
@Component
public class RolePreferenceToRolePreferenceVoMapperImpl implements RolePreferenceToRolePreferenceVoMapper {

    @Override
    public RolePreferenceVo convert(RolePreference arg0) {
        if ( arg0 == null ) {
            return null;
        }

        RolePreferenceVo rolePreferenceVo = new RolePreferenceVo();

        rolePreferenceVo.setId( arg0.getId() );
        rolePreferenceVo.setRoleId( arg0.getRoleId() );
        rolePreferenceVo.setPreferenceId( arg0.getPreferenceId() );
        rolePreferenceVo.setLevel( arg0.getLevel() );

        return rolePreferenceVo;
    }

    @Override
    public RolePreferenceVo convert(RolePreference arg0, RolePreferenceVo arg1) {
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
