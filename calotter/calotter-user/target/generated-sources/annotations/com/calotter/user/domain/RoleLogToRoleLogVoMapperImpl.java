package com.calotter.user.domain;

import com.calotter.user.domain.vo.RoleLogVo;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T13:57:48+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class RoleLogToRoleLogVoMapperImpl implements RoleLogToRoleLogVoMapper {

    @Override
    public RoleLogVo convert(RoleLog arg0) {
        if ( arg0 == null ) {
            return null;
        }

        RoleLogVo roleLogVo = new RoleLogVo();

        roleLogVo.setHeightCm( arg0.getHeightCm() );
        roleLogVo.setId( arg0.getId() );
        roleLogVo.setNotes( arg0.getNotes() );
        roleLogVo.setRecordAt( arg0.getRecordAt() );
        roleLogVo.setRoleId( arg0.getRoleId() );
        roleLogVo.setWeightKg( arg0.getWeightKg() );

        return roleLogVo;
    }

    @Override
    public RoleLogVo convert(RoleLog arg0, RoleLogVo arg1) {
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
