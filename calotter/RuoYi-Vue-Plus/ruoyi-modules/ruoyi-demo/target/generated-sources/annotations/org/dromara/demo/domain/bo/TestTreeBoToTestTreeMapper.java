package org.dromara.demo.domain.bo;

import io.github.linpeilie.AutoMapperConfig__228;
import io.github.linpeilie.BaseMapper;
import org.dromara.demo.domain.TestTree;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__228.class,
    uses = {},
    imports = {}
)
public interface TestTreeBoToTestTreeMapper extends BaseMapper<TestTreeBo, TestTree> {
}
