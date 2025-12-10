package io.github.linpeilie;

import org.dromara.demo.domain.TestDemoToTestDemoVoMapper;
import org.dromara.demo.domain.TestDemoToTestDemoVoMapper__2;
import org.dromara.demo.domain.TestTreeToTestTreeVoMapper;
import org.dromara.demo.domain.TestTreeToTestTreeVoMapper__2;
import org.dromara.demo.domain.bo.TestDemoBoToTestDemoMapper;
import org.dromara.demo.domain.bo.TestDemoBoToTestDemoMapper__2;
import org.dromara.demo.domain.bo.TestTreeBoToTestTreeMapper;
import org.dromara.demo.domain.bo.TestTreeBoToTestTreeMapper__2;
import org.dromara.demo.domain.vo.TestDemoVoToTestDemoMapper;
import org.dromara.demo.domain.vo.TestDemoVoToTestDemoMapper__2;
import org.dromara.demo.domain.vo.TestTreeVoToTestTreeMapper;
import org.dromara.demo.domain.vo.TestTreeVoToTestTreeMapper__2;
import org.mapstruct.Builder;
import org.mapstruct.MapperConfig;
import org.mapstruct.ReportingPolicy;

@MapperConfig(
    componentModel = "spring-lazy",
    uses = {ConverterMapperAdapter__53.class, TestTreeBoToTestTreeMapper__2.class, TestDemoToTestDemoVoMapper__2.class, TestDemoBoToTestDemoMapper__2.class, TestTreeVoToTestTreeMapper__2.class, TestDemoBoToTestDemoMapper.class, TestDemoToTestDemoVoMapper.class, TestTreeVoToTestTreeMapper.class, TestTreeBoToTestTreeMapper.class, TestTreeToTestTreeVoMapper__2.class, TestTreeToTestTreeVoMapper.class, TestDemoVoToTestDemoMapper.class, TestDemoVoToTestDemoMapper__2.class},
    unmappedTargetPolicy = ReportingPolicy.IGNORE,
    builder = @Builder(buildMethod = "build", disableBuilder = true)
)
public interface AutoMapperConfig__53 {
}
