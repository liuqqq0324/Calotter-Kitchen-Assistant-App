package io.github.linpeilie;

import org.dromara.workflow.domain.FlowCategoryToFlowCategoryVoMapper;
import org.dromara.workflow.domain.FlowSpelToFlowSpelVoMapper;
import org.dromara.workflow.domain.TestLeaveToTestLeaveVoMapper;
import org.dromara.workflow.domain.bo.FlowCategoryBoToFlowCategoryMapper;
import org.dromara.workflow.domain.bo.FlowSpelBoToFlowSpelMapper;
import org.dromara.workflow.domain.bo.TestLeaveBoToTestLeaveMapper;
import org.dromara.workflow.domain.vo.FlowCategoryVoToFlowCategoryMapper;
import org.dromara.workflow.domain.vo.FlowSpelVoToFlowSpelMapper;
import org.dromara.workflow.domain.vo.TestLeaveVoToTestLeaveMapper;
import org.mapstruct.Builder;
import org.mapstruct.MapperConfig;
import org.mapstruct.ReportingPolicy;

@MapperConfig(
    componentModel = "spring-lazy",
    uses = {ConverterMapperAdapter__39.class, FlowSpelToFlowSpelVoMapper.class, FlowCategoryBoToFlowCategoryMapper.class, FlowSpelVoToFlowSpelMapper.class, FlowSpelBoToFlowSpelMapper.class, TestLeaveToTestLeaveVoMapper.class, FlowCategoryVoToFlowCategoryMapper.class, TestLeaveBoToTestLeaveMapper.class, TestLeaveVoToTestLeaveMapper.class, FlowCategoryToFlowCategoryVoMapper.class},
    unmappedTargetPolicy = ReportingPolicy.IGNORE,
    builder = @Builder(buildMethod = "build", disableBuilder = true)
)
public interface AutoMapperConfig__39 {
}
