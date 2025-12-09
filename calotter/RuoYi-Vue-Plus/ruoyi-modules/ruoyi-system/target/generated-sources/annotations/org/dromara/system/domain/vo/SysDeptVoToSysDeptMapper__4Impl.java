package org.dromara.system.domain.vo;

import java.util.ArrayList;
import java.util.List;
import javax.annotation.processing.Generated;
import org.dromara.system.domain.SysDept;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-10T12:23:16+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class SysDeptVoToSysDeptMapper__4Impl implements SysDeptVoToSysDeptMapper__4 {

    @Override
    public SysDept convert(SysDeptVo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        SysDept sysDept = new SysDept();

        sysDept.setCreateTime( arg0.getCreateTime() );
        sysDept.setAncestors( arg0.getAncestors() );
        List<SysDept> list = arg0.getChildren();
        if ( list != null ) {
            sysDept.setChildren( new ArrayList<SysDept>( list ) );
        }
        sysDept.setDeptCategory( arg0.getDeptCategory() );
        sysDept.setDeptId( arg0.getDeptId() );
        sysDept.setDeptName( arg0.getDeptName() );
        sysDept.setEmail( arg0.getEmail() );
        sysDept.setLeader( arg0.getLeader() );
        sysDept.setOrderNum( arg0.getOrderNum() );
        sysDept.setParentId( arg0.getParentId() );
        sysDept.setPhone( arg0.getPhone() );
        sysDept.setStatus( arg0.getStatus() );

        return sysDept;
    }

    @Override
    public SysDept convert(SysDeptVo arg0, SysDept arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setCreateTime( arg0.getCreateTime() );
        arg1.setAncestors( arg0.getAncestors() );
        if ( arg1.getChildren() != null ) {
            List<SysDept> list = arg0.getChildren();
            if ( list != null ) {
                arg1.getChildren().clear();
                arg1.getChildren().addAll( list );
            }
            else {
                arg1.setChildren( null );
            }
        }
        else {
            List<SysDept> list = arg0.getChildren();
            if ( list != null ) {
                arg1.setChildren( new ArrayList<SysDept>( list ) );
            }
        }
        arg1.setDeptCategory( arg0.getDeptCategory() );
        arg1.setDeptId( arg0.getDeptId() );
        arg1.setDeptName( arg0.getDeptName() );
        arg1.setEmail( arg0.getEmail() );
        arg1.setLeader( arg0.getLeader() );
        arg1.setOrderNum( arg0.getOrderNum() );
        arg1.setParentId( arg0.getParentId() );
        arg1.setPhone( arg0.getPhone() );
        arg1.setStatus( arg0.getStatus() );

        return arg1;
    }
}
