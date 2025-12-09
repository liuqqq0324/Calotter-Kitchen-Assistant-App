package org.dromara.workflow.domain.vo;

import io.github.linpeilie.AutoMapperConfig__39;
import io.github.linpeilie.BaseMapper;
import org.dromara.workflow.domain.FlowCategory;
import org.dromara.workflow.domain.FlowCategoryToFlowCategoryVoMapper__1;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__39.class,
    uses = {FlowCategoryToFlowCategoryVoMapper__1.class},
    imports = {}
)
public interface FlowCategoryVoToFlowCategoryMapper__1 extends BaseMapper<FlowCategoryVo, FlowCategory> {
}
