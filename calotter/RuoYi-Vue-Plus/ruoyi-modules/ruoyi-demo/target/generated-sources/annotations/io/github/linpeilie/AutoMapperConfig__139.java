package io.github.linpeilie;

import org.dromara.demo.domain.TestDemoToTestDemoVoMapper__1;
import org.dromara.demo.domain.TestTreeToTestTreeVoMapper__1;
import org.dromara.demo.domain.bo.TestDemoBoToTestDemoMapper__1;
import org.dromara.demo.domain.bo.TestTreeBoToTestTreeMapper__1;
import org.dromara.demo.domain.vo.TestDemoVoToTestDemoMapper__1;
import org.dromara.demo.domain.vo.TestTreeVoToTestTreeMapper__1;
import org.mapstruct.Builder;
import org.mapstruct.MapperConfig;
import org.mapstruct.ReportingPolicy;

@MapperConfig(
    componentModel = "spring-lazy",
    uses = {ConverterMapperAdapter__139.class, TestTreeBoToTestTreeMapper__1.class, TestDemoBoToTestDemoMapper__1.class, TestTreeVoToTestTreeMapper__1.class, TestDemoVoToTestDemoMapper__1.class, TestDemoToTestDemoVoMapper__1.class, TestTreeToTestTreeVoMapper__1.class},
    unmappedTargetPolicy = ReportingPolicy.IGNORE,
    builder = @Builder(buildMethod = "build", disableBuilder = true)
)
public interface AutoMapperConfig__139 {
}
