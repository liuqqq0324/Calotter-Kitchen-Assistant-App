package org.dromara.workflow.domain.bo;

import java.util.LinkedHashMap;
import java.util.Map;
import javax.annotation.processing.Generated;
import org.dromara.workflow.domain.TestLeave;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T16:50:03+1300",
    comments = "version: 1.6.3, compiler: javac, environment: Java 25.0.1 (Homebrew)"
)
@Component
public class TestLeaveBoToTestLeaveMapperImpl implements TestLeaveBoToTestLeaveMapper {

    @Override
    public TestLeave convert(TestLeaveBo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        TestLeave testLeave = new TestLeave();

        testLeave.setSearchValue( arg0.getSearchValue() );
        testLeave.setCreateDept( arg0.getCreateDept() );
        testLeave.setCreateBy( arg0.getCreateBy() );
        testLeave.setCreateTime( arg0.getCreateTime() );
        testLeave.setUpdateBy( arg0.getUpdateBy() );
        testLeave.setUpdateTime( arg0.getUpdateTime() );
        Map<String, Object> map = arg0.getParams();
        if ( map != null ) {
            testLeave.setParams( new LinkedHashMap<String, Object>( map ) );
        }
        testLeave.setId( arg0.getId() );
        testLeave.setApplyCode( arg0.getApplyCode() );
        testLeave.setLeaveType( arg0.getLeaveType() );
        testLeave.setStartDate( arg0.getStartDate() );
        testLeave.setEndDate( arg0.getEndDate() );
        testLeave.setLeaveDays( arg0.getLeaveDays() );
        testLeave.setRemark( arg0.getRemark() );
        testLeave.setStatus( arg0.getStatus() );

        return testLeave;
    }

    @Override
    public TestLeave convert(TestLeaveBo arg0, TestLeave arg1) {
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
        arg1.setApplyCode( arg0.getApplyCode() );
        arg1.setLeaveType( arg0.getLeaveType() );
        arg1.setStartDate( arg0.getStartDate() );
        arg1.setEndDate( arg0.getEndDate() );
        arg1.setLeaveDays( arg0.getLeaveDays() );
        arg1.setRemark( arg0.getRemark() );
        arg1.setStatus( arg0.getStatus() );

        return arg1;
    }
}
