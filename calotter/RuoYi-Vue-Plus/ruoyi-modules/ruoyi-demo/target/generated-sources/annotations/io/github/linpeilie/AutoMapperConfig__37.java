package io.github.linpeilie;

import org.dromara.demo.domain.TestDemoToTestDemoVoMapper;
import org.dromara.demo.domain.TestTreeToTestTreeVoMapper;
import org.dromara.demo.domain.bo.TestDemoBoToTestDemoMapper;
import org.dromara.demo.domain.bo.TestTreeBoToTestTreeMapper;
import org.dromara.demo.domain.vo.TestDemoVoToTestDemoMapper;
import org.dromara.demo.domain.vo.TestTreeVoToTestTreeMapper;
import org.mapstruct.Builder;
import org.mapstruct.MapperConfig;
import org.mapstruct.ReportingPolicy;

@MapperConfig(
    componentModel = "spring-lazy",
    uses = {ConverterMapperAdapter__37.class, TestDemoBoToTestDemoMapper.class, TestDemoToTestDemoVoMapper.class, TestTreeVoToTestTreeMapper.class, TestTreeBoToTestTreeMapper.class, TestTreeToTestTreeVoMapper.class, TestDemoVoToTestDemoMapper.class},
    unmappedTargetPolicy = ReportingPolicy.IGNORE,
    builder = @Builder(buildMethod = "build", disableBuilder = true)
)
public interface AutoMapperConfig__37 {
}
