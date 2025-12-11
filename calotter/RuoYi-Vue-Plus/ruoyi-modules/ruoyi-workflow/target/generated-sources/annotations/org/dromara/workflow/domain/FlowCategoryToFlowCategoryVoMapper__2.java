package org.dromara.workflow.domain;

import io.github.linpeilie.AutoMapperConfig__115;
import io.github.linpeilie.BaseMapper;
import org.dromara.workflow.domain.bo.FlowCategoryBoToFlowCategoryMapper__2;
import org.dromara.workflow.domain.vo.FlowCategoryVo;
import org.dromara.workflow.domain.vo.FlowCategoryVoToFlowCategoryMapper__2;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__115.class,
    uses = {FlowCategoryVoToFlowCategoryMapper__2.class,FlowCategoryBoToFlowCategoryMapper__2.class},
    imports = {}
)
public interface FlowCategoryToFlowCategoryVoMapper__2 extends BaseMapper<FlowCategory, FlowCategoryVo> {
}
