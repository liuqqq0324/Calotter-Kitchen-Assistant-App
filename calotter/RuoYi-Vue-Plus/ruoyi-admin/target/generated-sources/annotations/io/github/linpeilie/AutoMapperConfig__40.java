package io.github.linpeilie;

import org.dromara.common.log.event.OperLogEventToSysOperLogBoMapper;
import org.dromara.system.domain.bo.SysOperLogBoToOperLogEventMapper;
import org.dromara.system.domain.bo.SysOperLogBoToSysOperLogMapper;
import org.dromara.system.domain.vo.SysTenantVoToTenantListVoMapper;
import org.dromara.web.domain.vo.TenantListVoToSysTenantVoMapper;
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
    uses = {ConverterMapperAdapter__40.class, FlowSpelToFlowSpelVoMapper.class, FlowSpelVoToFlowSpelMapper.class, FlowCategoryVoToFlowCategoryMapper.class, TestLeaveBoToTestLeaveMapper.class, SysTenantVoToTenantListVoMapper.class, SysOperLogBoToOperLogEventMapper.class, FlowCategoryBoToFlowCategoryMapper.class, FlowSpelBoToFlowSpelMapper.class, TestLeaveToTestLeaveVoMapper.class, TenantListVoToSysTenantVoMapper.class, OperLogEventToSysOperLogBoMapper.class, SysOperLogBoToSysOperLogMapper.class, TestLeaveVoToTestLeaveMapper.class, FlowCategoryToFlowCategoryVoMapper.class},
    unmappedTargetPolicy = ReportingPolicy.IGNORE,
    builder = @Builder(buildMethod = "build", disableBuilder = true)
)
public interface AutoMapperConfig__40 {
}
