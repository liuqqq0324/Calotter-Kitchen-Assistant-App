package org.dromara.workflow.domain;

import io.github.linpeilie.AutoMapperConfig__39;
import io.github.linpeilie.BaseMapper;
import org.dromara.workflow.domain.bo.FlowCategoryBoToFlowCategoryMapper__1;
import org.dromara.workflow.domain.vo.FlowCategoryVo;
import org.dromara.workflow.domain.vo.FlowCategoryVoToFlowCategoryMapper__1;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__39.class,
    uses = {FlowCategoryVoToFlowCategoryMapper__1.class,FlowCategoryBoToFlowCategoryMapper__1.class},
    imports = {}
)
public interface FlowCategoryToFlowCategoryVoMapper__1 extends BaseMapper<FlowCategory, FlowCategoryVo> {
}
