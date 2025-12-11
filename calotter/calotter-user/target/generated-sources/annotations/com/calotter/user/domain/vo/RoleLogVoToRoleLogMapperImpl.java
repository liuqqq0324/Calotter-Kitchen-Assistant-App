package com.calotter.user.domain.vo;

import com.calotter.user.domain.RoleLog;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T14:28:56+1300",
    comments = "version: 1.6.3, compiler: javac, environment: Java 21.0.8 (JetBrains s.r.o.)"
)
@Component
public class RoleLogVoToRoleLogMapperImpl implements RoleLogVoToRoleLogMapper {

    @Override
    public RoleLog convert(RoleLogVo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        RoleLog roleLog = new RoleLog();

        roleLog.setId( arg0.getId() );
        roleLog.setRoleId( arg0.getRoleId() );
        roleLog.setRecordAt( arg0.getRecordAt() );
        roleLog.setWeightKg( arg0.getWeightKg() );
        roleLog.setHeightCm( arg0.getHeightCm() );
        roleLog.setNotes( arg0.getNotes() );

        return roleLog;
    }

    @Override
    public RoleLog convert(RoleLogVo arg0, RoleLog arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setId( arg0.getId() );
        arg1.setRoleId( arg0.getRoleId() );
        arg1.setRecordAt( arg0.getRecordAt() );
        arg1.setWeightKg( arg0.getWeightKg() );
        arg1.setHeightCm( arg0.getHeightCm() );
        arg1.setNotes( arg0.getNotes() );

        return arg1;
    }
}
