package org.dromara.demo.domain.vo;

import io.github.linpeilie.AutoMapperConfig__113;
import io.github.linpeilie.BaseMapper;
import org.dromara.demo.domain.TestDemo;
import org.dromara.demo.domain.TestDemoToTestDemoVoMapper__1;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__113.class,
    uses = {TestDemoToTestDemoVoMapper__1.class},
    imports = {}
)
public interface TestDemoVoToTestDemoMapper__1 extends BaseMapper<TestDemoVo, TestDemo> {
}
