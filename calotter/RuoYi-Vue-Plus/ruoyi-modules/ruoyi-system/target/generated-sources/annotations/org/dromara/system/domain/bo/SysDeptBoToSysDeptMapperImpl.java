package org.dromara.system.domain.bo;

import java.util.LinkedHashMap;
import java.util.Map;
import javax.annotation.processing.Generated;
import org.dromara.system.domain.SysDept;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
<<<<<<< HEAD
    date = "2025-12-10T15:10:35+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
=======
    date = "2025-12-10T13:27:22+1300",
    comments = "version: 1.6.3, compiler: javac, environment: Java 25.0.1 (Homebrew)"
>>>>>>> chase/flutter-v1-android-java
)
@Component
public class SysDeptBoToSysDeptMapperImpl implements SysDeptBoToSysDeptMapper {

    @Override
    public SysDept convert(SysDeptBo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        SysDept sysDept = new SysDept();

        sysDept.setSearchValue( arg0.getSearchValue() );
        sysDept.setCreateDept( arg0.getCreateDept() );
        sysDept.setCreateBy( arg0.getCreateBy() );
        sysDept.setCreateTime( arg0.getCreateTime() );
        sysDept.setUpdateBy( arg0.getUpdateBy() );
        sysDept.setUpdateTime( arg0.getUpdateTime() );
        Map<String, Object> map = arg0.getParams();
        if ( map != null ) {
            sysDept.setParams( new LinkedHashMap<String, Object>( map ) );
        }
        sysDept.setDeptId( arg0.getDeptId() );
        sysDept.setParentId( arg0.getParentId() );
        sysDept.setDeptName( arg0.getDeptName() );
        sysDept.setDeptCategory( arg0.getDeptCategory() );
        sysDept.setOrderNum( arg0.getOrderNum() );
        sysDept.setLeader( arg0.getLeader() );
        sysDept.setPhone( arg0.getPhone() );
        sysDept.setEmail( arg0.getEmail() );
        sysDept.setStatus( arg0.getStatus() );

        return sysDept;
    }

    @Override
    public SysDept convert(SysDeptBo arg0, SysDept arg1) {
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
        arg1.setDeptId( arg0.getDeptId() );
        arg1.setParentId( arg0.getParentId() );
        arg1.setDeptName( arg0.getDeptName() );
        arg1.setDeptCategory( arg0.getDeptCategory() );
        arg1.setOrderNum( arg0.getOrderNum() );
        arg1.setLeader( arg0.getLeader() );
        arg1.setPhone( arg0.getPhone() );
        arg1.setEmail( arg0.getEmail() );
        arg1.setStatus( arg0.getStatus() );

        return arg1;
    }
}
