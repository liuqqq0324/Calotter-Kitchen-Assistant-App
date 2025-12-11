package com.calotter.user.domain.bo;

import com.calotter.user.domain.RoleLog;
import java.util.LinkedHashMap;
import java.util.Map;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T14:28:56+1300",
    comments = "version: 1.6.3, compiler: javac, environment: Java 21.0.8 (JetBrains s.r.o.)"
)
@Component
public class RoleLogBoToRoleLogMapperImpl implements RoleLogBoToRoleLogMapper {

    @Override
    public RoleLog convert(RoleLogBo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        RoleLog roleLog = new RoleLog();

        roleLog.setSearchValue( arg0.getSearchValue() );
        roleLog.setCreateDept( arg0.getCreateDept() );
        roleLog.setCreateBy( arg0.getCreateBy() );
        roleLog.setCreateTime( arg0.getCreateTime() );
        roleLog.setUpdateBy( arg0.getUpdateBy() );
        roleLog.setUpdateTime( arg0.getUpdateTime() );
        Map<String, Object> map = arg0.getParams();
        if ( map != null ) {
            roleLog.setParams( new LinkedHashMap<String, Object>( map ) );
        }
        roleLog.setId( arg0.getId() );
        roleLog.setRoleId( arg0.getRoleId() );
        roleLog.setRecordAt( arg0.getRecordAt() );
        roleLog.setWeightKg( arg0.getWeightKg() );
        roleLog.setHeightCm( arg0.getHeightCm() );
        roleLog.setNotes( arg0.getNotes() );

        return roleLog;
    }

    @Override
    public RoleLog convert(RoleLogBo arg0, RoleLog arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setSearchValue( arg0.getSearchValue() );
        arg1.setCreateDept( arg0.getCreateDept() );
        arg1.setCreateBy( arg0.getCreateBy() );
        arg1.setCreateTime( arg0.getCreateTime() );
        arg1.setUpdateBy( arg0.getUpdateBy() );
        arg1.setUpdateTime( arg0.getUpdateTime() );
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
        arg1.setId( arg0.getId() );
        arg1.setRoleId( arg0.getRoleId() );
        arg1.setRecordAt( arg0.getRecordAt() );
        arg1.setWeightKg( arg0.getWeightKg() );
        arg1.setHeightCm( arg0.getHeightCm() );
        arg1.setNotes( arg0.getNotes() );

        return arg1;
    }
}
