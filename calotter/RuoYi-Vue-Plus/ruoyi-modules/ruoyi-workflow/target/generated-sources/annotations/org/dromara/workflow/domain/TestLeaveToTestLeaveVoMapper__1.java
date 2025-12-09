package org.dromara.workflow.domain;

import io.github.linpeilie.AutoMapperConfig__39;
import io.github.linpeilie.BaseMapper;
import org.dromara.workflow.domain.bo.TestLeaveBoToTestLeaveMapper__1;
import org.dromara.workflow.domain.vo.TestLeaveVo;
import org.dromara.workflow.domain.vo.TestLeaveVoToTestLeaveMapper__1;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__39.class,
    uses = {TestLeaveVoToTestLeaveMapper__1.class,TestLeaveBoToTestLeaveMapper__1.class},
    imports = {}
)
public interface TestLeaveToTestLeaveVoMapper__1 extends BaseMapper<TestLeave, TestLeaveVo> {
}
