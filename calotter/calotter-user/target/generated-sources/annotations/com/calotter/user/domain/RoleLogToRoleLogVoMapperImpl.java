package com.calotter.user.domain;

import com.calotter.user.domain.vo.RoleLogVo;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T14:28:56+1300",
    comments = "version: 1.6.3, compiler: javac, environment: Java 21.0.8 (JetBrains s.r.o.)"
)
@Component
public class RoleLogToRoleLogVoMapperImpl implements RoleLogToRoleLogVoMapper {

    @Override
    public RoleLogVo convert(RoleLog arg0) {
        if ( arg0 == null ) {
            return null;
        }

        RoleLogVo roleLogVo = new RoleLogVo();

        roleLogVo.setId( arg0.getId() );
        roleLogVo.setRoleId( arg0.getRoleId() );
        roleLogVo.setRecordAt( arg0.getRecordAt() );
        roleLogVo.setWeightKg( arg0.getWeightKg() );
        roleLogVo.setHeightCm( arg0.getHeightCm() );
        roleLogVo.setNotes( arg0.getNotes() );

        return roleLogVo;
    }

    @Override
    public RoleLogVo convert(RoleLog arg0, RoleLogVo arg1) {
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
