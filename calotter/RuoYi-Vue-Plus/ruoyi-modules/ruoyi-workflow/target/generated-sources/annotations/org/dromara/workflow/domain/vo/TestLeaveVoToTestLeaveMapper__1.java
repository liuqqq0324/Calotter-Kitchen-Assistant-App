package org.dromara.workflow.domain.vo;

import io.github.linpeilie.AutoMapperConfig__39;
import io.github.linpeilie.BaseMapper;
import org.dromara.workflow.domain.TestLeave;
import org.dromara.workflow.domain.TestLeaveToTestLeaveVoMapper__1;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__39.class,
    uses = {TestLeaveToTestLeaveVoMapper__1.class},
    imports = {}
)
public interface TestLeaveVoToTestLeaveMapper__1 extends BaseMapper<TestLeaveVo, TestLeave> {
}
