package io.github.linpeilie;

import org.dromara.workflow.domain.FlowCategoryToFlowCategoryVoMapper;
import org.dromara.workflow.domain.FlowCategoryToFlowCategoryVoMapper__1;
import org.dromara.workflow.domain.FlowSpelToFlowSpelVoMapper;
import org.dromara.workflow.domain.FlowSpelToFlowSpelVoMapper__1;
import org.dromara.workflow.domain.TestLeaveToTestLeaveVoMapper;
import org.dromara.workflow.domain.TestLeaveToTestLeaveVoMapper__1;
import org.dromara.workflow.domain.bo.FlowCategoryBoToFlowCategoryMapper;
import org.dromara.workflow.domain.bo.FlowCategoryBoToFlowCategoryMapper__1;
import org.dromara.workflow.domain.bo.FlowSpelBoToFlowSpelMapper;
import org.dromara.workflow.domain.bo.FlowSpelBoToFlowSpelMapper__1;
import org.dromara.workflow.domain.bo.TestLeaveBoToTestLeaveMapper;
import org.dromara.workflow.domain.bo.TestLeaveBoToTestLeaveMapper__1;
import org.dromara.workflow.domain.vo.FlowCategoryVoToFlowCategoryMapper;
import org.dromara.workflow.domain.vo.FlowCategoryVoToFlowCategoryMapper__1;
import org.dromara.workflow.domain.vo.FlowSpelVoToFlowSpelMapper;
import org.dromara.workflow.domain.vo.FlowSpelVoToFlowSpelMapper__1;
import org.dromara.workflow.domain.vo.TestLeaveVoToTestLeaveMapper;
import org.dromara.workflow.domain.vo.TestLeaveVoToTestLeaveMapper__1;
import org.mapstruct.Builder;
import org.mapstruct.MapperConfig;
import org.mapstruct.ReportingPolicy;

@MapperConfig(
    componentModel = "spring-lazy",
    uses = {ConverterMapperAdapter__55.class, FlowCategoryBoToFlowCategoryMapper__1.class, FlowSpelToFlowSpelVoMapper.class, FlowSpelBoToFlowSpelMapper__1.class, FlowCategoryBoToFlowCategoryMapper.class, FlowCategoryVoToFlowCategoryMapper__1.class, FlowSpelVoToFlowSpelMapper.class, FlowSpelBoToFlowSpelMapper.class, TestLeaveToTestLeaveVoMapper.class, TestLeaveToTestLeaveVoMapper__1.class, FlowCategoryVoToFlowCategoryMapper.class, FlowCategoryToFlowCategoryVoMapper__1.class, TestLeaveVoToTestLeaveMapper__1.class, FlowSpelToFlowSpelVoMapper__1.class, TestLeaveBoToTestLeaveMapper.class, FlowSpelVoToFlowSpelMapper__1.class, TestLeaveVoToTestLeaveMapper.class, TestLeaveBoToTestLeaveMapper__1.class, FlowCategoryToFlowCategoryVoMapper.class},
    unmappedTargetPolicy = ReportingPolicy.IGNORE,
    builder = @Builder(buildMethod = "build", disableBuilder = true)
)
public interface AutoMapperConfig__55 {
}
