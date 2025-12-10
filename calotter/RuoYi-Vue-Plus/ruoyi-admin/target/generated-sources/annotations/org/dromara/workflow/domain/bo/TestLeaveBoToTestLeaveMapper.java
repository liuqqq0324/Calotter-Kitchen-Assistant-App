package org.dromara.workflow.domain.bo;

import io.github.linpeilie.AutoMapperConfig__56;
import io.github.linpeilie.BaseMapper;
import org.dromara.workflow.domain.TestLeave;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__56.class,
    uses = {},
    imports = {}
)
public interface TestLeaveBoToTestLeaveMapper extends BaseMapper<TestLeaveBo, TestLeave> {
}
