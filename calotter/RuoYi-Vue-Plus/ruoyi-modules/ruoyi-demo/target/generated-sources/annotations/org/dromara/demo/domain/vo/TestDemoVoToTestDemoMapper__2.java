package org.dromara.demo.domain.vo;

import io.github.linpeilie.AutoMapperConfig__37;
import io.github.linpeilie.BaseMapper;
import org.dromara.demo.domain.TestDemo;
import org.dromara.demo.domain.TestDemoToTestDemoVoMapper__2;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__37.class,
    uses = {TestDemoToTestDemoVoMapper__2.class},
    imports = {}
)
public interface TestDemoVoToTestDemoMapper__2 extends BaseMapper<TestDemoVo, TestDemo> {
}
