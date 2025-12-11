package org.dromara.system.domain;

import java.util.ArrayList;
import java.util.List;
import javax.annotation.processing.Generated;
import org.dromara.system.domain.vo.SysDeptVo;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-10T13:27:22+1300",
    comments = "version: 1.6.3, compiler: javac, environment: Java 25.0.1 (Homebrew)"
)
@Component
public class SysDeptToSysDeptVoMapperImpl implements SysDeptToSysDeptVoMapper {

    @Override
    public SysDeptVo convert(SysDept arg0) {
        if ( arg0 == null ) {
            return null;
        }

        SysDeptVo sysDeptVo = new SysDeptVo();

        sysDeptVo.setDeptId( arg0.getDeptId() );
        sysDeptVo.setParentId( arg0.getParentId() );
        sysDeptVo.setAncestors( arg0.getAncestors() );
        sysDeptVo.setDeptName( arg0.getDeptName() );
        sysDeptVo.setDeptCategory( arg0.getDeptCategory() );
        sysDeptVo.setOrderNum( arg0.getOrderNum() );
        sysDeptVo.setLeader( arg0.getLeader() );
        sysDeptVo.setPhone( arg0.getPhone() );
        sysDeptVo.setEmail( arg0.getEmail() );
        sysDeptVo.setStatus( arg0.getStatus() );
        sysDeptVo.setCreateTime( arg0.getCreateTime() );
        List<SysDept> list = arg0.getChildren();
        if ( list != null ) {
            sysDeptVo.setChildren( new ArrayList<SysDept>( list ) );
        }

        return sysDeptVo;
    }

    @Override
    public SysDeptVo convert(SysDept arg0, SysDeptVo arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setDeptId( arg0.getDeptId() );
        arg1.setParentId( arg0.getParentId() );
        arg1.setAncestors( arg0.getAncestors() );
        arg1.setDeptName( arg0.getDeptName() );
        arg1.setDeptCategory( arg0.getDeptCategory() );
        arg1.setOrderNum( arg0.getOrderNum() );
        arg1.setLeader( arg0.getLeader() );
        arg1.setPhone( arg0.getPhone() );
        arg1.setEmail( arg0.getEmail() );
        arg1.setStatus( arg0.getStatus() );
        arg1.setCreateTime( arg0.getCreateTime() );
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

        return arg1;
    }
}
