package org.dromara.demo.domain.vo;

import io.github.linpeilie.AutoMapperConfig__113;
import io.github.linpeilie.BaseMapper;
import org.dromara.demo.domain.TestTree;
import org.dromara.demo.domain.TestTreeToTestTreeVoMapper__1;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__113.class,
    uses = {TestTreeToTestTreeVoMapper__1.class},
    imports = {}
)
public interface TestTreeVoToTestTreeMapper__1 extends BaseMapper<TestTreeVo, TestTree> {
}
