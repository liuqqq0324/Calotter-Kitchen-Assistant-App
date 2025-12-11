package org.dromara.workflow.domain.bo;

import io.github.linpeilie.AutoMapperConfig__154;
import io.github.linpeilie.BaseMapper;
import org.dromara.workflow.domain.TestLeave;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__154.class,
    uses = {},
    imports = {}
)
public interface TestLeaveBoToTestLeaveMapper extends BaseMapper<TestLeaveBo, TestLeave> {
}
