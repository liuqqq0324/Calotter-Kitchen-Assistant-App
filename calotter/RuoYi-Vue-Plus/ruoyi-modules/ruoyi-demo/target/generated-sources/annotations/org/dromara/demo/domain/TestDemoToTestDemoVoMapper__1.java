package org.dromara.demo.domain;

import io.github.linpeilie.AutoMapperConfig__113;
import io.github.linpeilie.BaseMapper;
import org.dromara.demo.domain.bo.TestDemoBoToTestDemoMapper__1;
import org.dromara.demo.domain.vo.TestDemoVo;
import org.dromara.demo.domain.vo.TestDemoVoToTestDemoMapper__1;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__113.class,
    uses = {TestDemoVoToTestDemoMapper__1.class,TestDemoBoToTestDemoMapper__1.class},
    imports = {}
)
public interface TestDemoToTestDemoVoMapper__1 extends BaseMapper<TestDemo, TestDemoVo> {
}
