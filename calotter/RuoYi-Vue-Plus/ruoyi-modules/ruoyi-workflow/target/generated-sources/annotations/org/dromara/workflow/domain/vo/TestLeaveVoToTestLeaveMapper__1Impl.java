package org.dromara.workflow.domain.vo;

import javax.annotation.processing.Generated;
import org.dromara.workflow.domain.TestLeave;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-10T12:23:29+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class TestLeaveVoToTestLeaveMapper__1Impl implements TestLeaveVoToTestLeaveMapper__1 {

    @Override
    public TestLeave convert(TestLeaveVo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        TestLeave testLeave = new TestLeave();

        testLeave.setApplyCode( arg0.getApplyCode() );
        testLeave.setEndDate( arg0.getEndDate() );
        testLeave.setId( arg0.getId() );
        testLeave.setLeaveDays( arg0.getLeaveDays() );
        testLeave.setLeaveType( arg0.getLeaveType() );
        testLeave.setRemark( arg0.getRemark() );
        testLeave.setStartDate( arg0.getStartDate() );
        testLeave.setStatus( arg0.getStatus() );

        return testLeave;
    }

    @Override
    public TestLeave convert(TestLeaveVo arg0, TestLeave arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setApplyCode( arg0.getApplyCode() );
        arg1.setEndDate( arg0.getEndDate() );
        arg1.setId( arg0.getId() );
        arg1.setLeaveDays( arg0.getLeaveDays() );
        arg1.setLeaveType( arg0.getLeaveType() );
        arg1.setRemark( arg0.getRemark() );
        arg1.setStartDate( arg0.getStartDate() );
        arg1.setStatus( arg0.getStatus() );

        return arg1;
    }
}
