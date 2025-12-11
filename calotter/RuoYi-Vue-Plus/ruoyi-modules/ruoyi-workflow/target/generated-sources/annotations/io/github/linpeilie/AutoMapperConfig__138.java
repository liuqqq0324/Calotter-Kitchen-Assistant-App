package io.github.linpeilie;

import org.dromara.workflow.domain.FlowCategoryToFlowCategoryVoMapper__2;
import org.dromara.workflow.domain.FlowSpelToFlowSpelVoMapper__2;
import org.dromara.workflow.domain.TestLeaveToTestLeaveVoMapper__2;
import org.dromara.workflow.domain.bo.FlowCategoryBoToFlowCategoryMapper__2;
import org.dromara.workflow.domain.bo.FlowSpelBoToFlowSpelMapper__2;
import org.dromara.workflow.domain.bo.TestLeaveBoToTestLeaveMapper__2;
import org.dromara.workflow.domain.vo.FlowCategoryVoToFlowCategoryMapper__2;
import org.dromara.workflow.domain.vo.FlowSpelVoToFlowSpelMapper__2;
import org.dromara.workflow.domain.vo.TestLeaveVoToTestLeaveMapper__2;
import org.mapstruct.Builder;
import org.mapstruct.MapperConfig;
import org.mapstruct.ReportingPolicy;

@MapperConfig(
    componentModel = "spring-lazy",
    uses = {ConverterMapperAdapter__138.class, FlowCategoryBoToFlowCategoryMapper__2.class, FlowCategoryVoToFlowCategoryMapper__2.class, FlowSpelBoToFlowSpelMapper__2.class, TestLeaveToTestLeaveVoMapper__2.class, FlowCategoryToFlowCategoryVoMapper__2.class, TestLeaveVoToTestLeaveMapper__2.class, FlowSpelToFlowSpelVoMapper__2.class, FlowSpelVoToFlowSpelMapper__2.class, TestLeaveBoToTestLeaveMapper__2.class},
    unmappedTargetPolicy = ReportingPolicy.IGNORE,
    builder = @Builder(buildMethod = "build", disableBuilder = true)
)
public interface AutoMapperConfig__138 {
}
