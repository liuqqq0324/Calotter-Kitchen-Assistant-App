package org.dromara.demo.domain.bo;

import io.github.linpeilie.AutoMapperConfig__113;
import io.github.linpeilie.BaseMapper;
import org.dromara.demo.domain.TestDemo;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__113.class,
    uses = {},
    imports = {}
)
public interface TestDemoBoToTestDemoMapper__1 extends BaseMapper<TestDemoBo, TestDemo> {
}
