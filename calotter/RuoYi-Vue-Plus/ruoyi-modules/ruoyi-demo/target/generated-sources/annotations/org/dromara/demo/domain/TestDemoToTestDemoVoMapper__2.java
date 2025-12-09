package org.dromara.demo.domain;

import io.github.linpeilie.AutoMapperConfig__37;
import io.github.linpeilie.BaseMapper;
import org.dromara.demo.domain.bo.TestDemoBoToTestDemoMapper__2;
import org.dromara.demo.domain.vo.TestDemoVo;
import org.dromara.demo.domain.vo.TestDemoVoToTestDemoMapper__2;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__37.class,
    uses = {TestDemoVoToTestDemoMapper__2.class,TestDemoBoToTestDemoMapper__2.class},
    imports = {}
)
public interface TestDemoToTestDemoVoMapper__2 extends BaseMapper<TestDemo, TestDemoVo> {
}
