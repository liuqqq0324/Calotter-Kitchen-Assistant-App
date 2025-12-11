package org.dromara.workflow.domain;

import io.github.linpeilie.AutoMapperConfig__115;
import io.github.linpeilie.BaseMapper;
import org.dromara.workflow.domain.bo.TestLeaveBoToTestLeaveMapper__2;
import org.dromara.workflow.domain.vo.TestLeaveVo;
import org.dromara.workflow.domain.vo.TestLeaveVoToTestLeaveMapper__2;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__115.class,
    uses = {TestLeaveVoToTestLeaveMapper__2.class,TestLeaveBoToTestLeaveMapper__2.class},
    imports = {}
)
public interface TestLeaveToTestLeaveVoMapper__2 extends BaseMapper<TestLeave, TestLeaveVo> {
}
