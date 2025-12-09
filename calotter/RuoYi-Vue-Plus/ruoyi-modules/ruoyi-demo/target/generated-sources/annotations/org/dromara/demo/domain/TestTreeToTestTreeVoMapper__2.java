package org.dromara.demo.domain;

import io.github.linpeilie.AutoMapperConfig__37;
import io.github.linpeilie.BaseMapper;
import org.dromara.demo.domain.bo.TestTreeBoToTestTreeMapper__2;
import org.dromara.demo.domain.vo.TestTreeVo;
import org.dromara.demo.domain.vo.TestTreeVoToTestTreeMapper__2;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__37.class,
    uses = {TestTreeVoToTestTreeMapper__2.class,TestTreeBoToTestTreeMapper__2.class},
    imports = {}
)
public interface TestTreeToTestTreeVoMapper__2 extends BaseMapper<TestTree, TestTreeVo> {
}
