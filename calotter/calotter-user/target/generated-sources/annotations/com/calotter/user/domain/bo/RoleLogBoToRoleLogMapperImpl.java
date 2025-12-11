package com.calotter.user.domain.bo;

import com.calotter.user.domain.RoleLog;
import java.util.LinkedHashMap;
import java.util.Map;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T13:57:48+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class RoleLogBoToRoleLogMapperImpl implements RoleLogBoToRoleLogMapper {

    @Override
    public RoleLog convert(RoleLogBo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        RoleLog roleLog = new RoleLog();

        roleLog.setCreateBy( arg0.getCreateBy() );
        roleLog.setCreateDept( arg0.getCreateDept() );
        roleLog.setCreateTime( arg0.getCreateTime() );
        Map<String, Object> map = arg0.getParams();
        if ( map != null ) {
            roleLog.setParams( new LinkedHashMap<String, Object>( map ) );
        }
        roleLog.setSearchValue( arg0.getSearchValue() );
        roleLog.setUpdateBy( arg0.getUpdateBy() );
        roleLog.setUpdateTime( arg0.getUpdateTime() );
        roleLog.setHeightCm( arg0.getHeightCm() );
        roleLog.setId( arg0.getId() );
        roleLog.setNotes( arg0.getNotes() );
        roleLog.setRecordAt( arg0.getRecordAt() );
        roleLog.setRoleId( arg0.getRoleId() );
        roleLog.setWeightKg( arg0.getWeightKg() );

        return roleLog;
    }

    @Override
    public RoleLog convert(RoleLogBo arg0, RoleLog arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setCreateBy( arg0.getCreateBy() );
        arg1.setCreateDept( arg0.getCreateDept() );
        arg1.setCreateTime( arg0.getCreateTime() );
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
        arg1.setSearchValue( arg0.getSearchValue() );
        arg1.setUpdateBy( arg0.getUpdateBy() );
        arg1.setUpdateTime( arg0.getUpdateTime() );
        arg1.setHeightCm( arg0.getHeightCm() );
        arg1.setId( arg0.getId() );
        arg1.setNotes( arg0.getNotes() );
        arg1.setRecordAt( arg0.getRecordAt() );
        arg1.setRoleId( arg0.getRoleId() );
        arg1.setWeightKg( arg0.getWeightKg() );

        return arg1;
    }
}
