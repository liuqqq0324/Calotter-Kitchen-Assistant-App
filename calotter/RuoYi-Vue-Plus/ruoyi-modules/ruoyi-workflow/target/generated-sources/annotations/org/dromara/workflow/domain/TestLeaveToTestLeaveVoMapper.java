package org.dromara.workflow.domain;

import io.github.linpeilie.AutoMapperConfig__154;
import io.github.linpeilie.BaseMapper;
import org.dromara.workflow.domain.bo.TestLeaveBoToTestLeaveMapper;
import org.dromara.workflow.domain.vo.TestLeaveVo;
import org.dromara.workflow.domain.vo.TestLeaveVoToTestLeaveMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__154.class,
    uses = {TestLeaveVoToTestLeaveMapper.class,TestLeaveBoToTestLeaveMapper.class},
    imports = {}
)
public interface TestLeaveToTestLeaveVoMapper extends BaseMapper<TestLeave, TestLeaveVo> {
}
