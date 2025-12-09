package org.dromara.demo.domain.bo;

import io.github.linpeilie.AutoMapperConfig__37;
import io.github.linpeilie.BaseMapper;
import org.dromara.demo.domain.TestDemo;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__37.class,
    uses = {},
    imports = {}
)
public interface TestDemoBoToTestDemoMapper__2 extends BaseMapper<TestDemoBo, TestDemo> {
}
