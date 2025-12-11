package org.dromara.workflow.domain;

import javax.annotation.processing.Generated;
import org.dromara.workflow.domain.vo.TestLeaveVo;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T13:58:12+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class TestLeaveToTestLeaveVoMapper__2Impl implements TestLeaveToTestLeaveVoMapper__2 {

    @Override
    public TestLeaveVo convert(TestLeave arg0) {
        if ( arg0 == null ) {
            return null;
        }

        TestLeaveVo testLeaveVo = new TestLeaveVo();

        testLeaveVo.setId( arg0.getId() );
        testLeaveVo.setApplyCode( arg0.getApplyCode() );
        testLeaveVo.setLeaveType( arg0.getLeaveType() );
        testLeaveVo.setStartDate( arg0.getStartDate() );
        testLeaveVo.setEndDate( arg0.getEndDate() );
        testLeaveVo.setLeaveDays( arg0.getLeaveDays() );
        testLeaveVo.setRemark( arg0.getRemark() );
        testLeaveVo.setStatus( arg0.getStatus() );

        return testLeaveVo;
    }

    @Override
    public TestLeaveVo convert(TestLeave arg0, TestLeaveVo arg1) {
        if ( arg0 == null ) {
            return arg1;
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
