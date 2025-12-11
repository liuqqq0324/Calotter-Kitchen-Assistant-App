package org.dromara.demo.domain;

import io.github.linpeilie.AutoMapperConfig__113;
import io.github.linpeilie.BaseMapper;
import org.dromara.demo.domain.bo.TestTreeBoToTestTreeMapper__1;
import org.dromara.demo.domain.vo.TestTreeVo;
import org.dromara.demo.domain.vo.TestTreeVoToTestTreeMapper__1;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__113.class,
    uses = {TestTreeVoToTestTreeMapper__1.class,TestTreeBoToTestTreeMapper__1.class},
    imports = {}
)
public interface TestTreeToTestTreeVoMapper__1 extends BaseMapper<TestTree, TestTreeVo> {
}
