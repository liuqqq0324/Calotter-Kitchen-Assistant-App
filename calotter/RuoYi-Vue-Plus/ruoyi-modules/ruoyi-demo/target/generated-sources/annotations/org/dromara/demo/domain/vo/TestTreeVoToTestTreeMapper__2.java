package org.dromara.demo.domain.vo;

import io.github.linpeilie.AutoMapperConfig__37;
import io.github.linpeilie.BaseMapper;
import org.dromara.demo.domain.TestTree;
import org.dromara.demo.domain.TestTreeToTestTreeVoMapper__2;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__37.class,
    uses = {TestTreeToTestTreeVoMapper__2.class},
    imports = {}
)
public interface TestTreeVoToTestTreeMapper__2 extends BaseMapper<TestTreeVo, TestTree> {
}
