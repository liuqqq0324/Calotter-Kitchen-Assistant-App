package io.github.linpeilie;

import org.dromara.common.log.event.OperLogEventToSysOperLogBoMapper__4;
import org.dromara.demo.domain.TestDemoToTestDemoVoMapper__1;
import org.dromara.demo.domain.TestTreeToTestTreeVoMapper__1;
import org.dromara.demo.domain.bo.TestDemoBoToTestDemoMapper__1;
import org.dromara.demo.domain.bo.TestTreeBoToTestTreeMapper__1;
import org.dromara.demo.domain.vo.TestDemoVoToTestDemoMapper__1;
import org.dromara.demo.domain.vo.TestTreeVoToTestTreeMapper__1;
import org.dromara.system.domain.bo.SysOperLogBoToOperLogEventMapper__4;
import org.dromara.system.domain.bo.SysOperLogBoToSysOperLogMapper__4;
import org.dromara.system.domain.vo.SysTenantVoToTenantListVoMapper__4;
import org.dromara.web.domain.vo.TenantListVoToSysTenantVoMapper__4;
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
    uses = {ConverterMapperAdapter__140.class, TestTreeBoToTestTreeMapper__1.class, FlowCategoryBoToFlowCategoryMapper__2.class, SysOperLogBoToSysOperLogMapper__4.class, FlowCategoryVoToFlowCategoryMapper__2.class, FlowSpelBoToFlowSpelMapper__2.class, TestDemoBoToTestDemoMapper__1.class, TestTreeVoToTestTreeMapper__1.class, SysTenantVoToTenantListVoMapper__4.class, TestDemoToTestDemoVoMapper__1.class, TestLeaveToTestLeaveVoMapper__2.class, FlowCategoryToFlowCategoryVoMapper__2.class, SysOperLogBoToOperLogEventMapper__4.class, TestLeaveVoToTestLeaveMapper__2.class, FlowSpelToFlowSpelVoMapper__2.class, TenantListVoToSysTenantVoMapper__4.class, FlowSpelVoToFlowSpelMapper__2.class, OperLogEventToSysOperLogBoMapper__4.class, TestDemoVoToTestDemoMapper__1.class, TestLeaveBoToTestLeaveMapper__2.class, TestTreeToTestTreeVoMapper__1.class},
    unmappedTargetPolicy = ReportingPolicy.IGNORE,
    builder = @Builder(buildMethod = "build", disableBuilder = true)
)
public interface AutoMapperConfig__140 {
}
