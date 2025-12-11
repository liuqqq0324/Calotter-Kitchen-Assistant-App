package com.calotter.user.domain.vo;

import com.calotter.user.domain.RoleLog;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T17:42:11+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class RoleLogVoToRoleLogMapperImpl implements RoleLogVoToRoleLogMapper {

    @Override
    public RoleLog convert(RoleLogVo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        RoleLog roleLog = new RoleLog();

        roleLog.setHeightCm( arg0.getHeightCm() );
        roleLog.setId( arg0.getId() );
        roleLog.setNotes( arg0.getNotes() );
        roleLog.setRecordAt( arg0.getRecordAt() );
        roleLog.setRoleId( arg0.getRoleId() );
        roleLog.setWeightKg( arg0.getWeightKg() );

        return roleLog;
    }

    @Override
    public RoleLog convert(RoleLogVo arg0, RoleLog arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setHeightCm( arg0.getHeightCm() );
        arg1.setId( arg0.getId() );
        arg1.setNotes( arg0.getNotes() );
        arg1.setRecordAt( arg0.getRecordAt() );
        arg1.setRoleId( arg0.getRoleId() );
        arg1.setWeightKg( arg0.getWeightKg() );

        return arg1;
    }
}
