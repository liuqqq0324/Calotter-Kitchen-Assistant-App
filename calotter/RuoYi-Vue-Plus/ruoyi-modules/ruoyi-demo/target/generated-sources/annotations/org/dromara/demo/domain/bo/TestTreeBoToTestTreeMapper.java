package org.dromara.demo.domain.bo;

import io.github.linpeilie.AutoMapperConfig__139;
import io.github.linpeilie.BaseMapper;
import org.dromara.demo.domain.TestTree;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__139.class,
    uses = {},
    imports = {}
)
public interface TestTreeBoToTestTreeMapper extends BaseMapper<TestTreeBo, TestTree> {
}
