package org.dromara.workflow.domain.vo;

import io.github.linpeilie.AutoMapperConfig__117;
import io.github.linpeilie.BaseMapper;
import org.dromara.workflow.domain.FlowCategory;
import org.dromara.workflow.domain.FlowCategoryToFlowCategoryVoMapper__2;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__117.class,
    uses = {FlowCategoryToFlowCategoryVoMapper__2.class},
    imports = {}
)
public interface FlowCategoryVoToFlowCategoryMapper__2 extends BaseMapper<FlowCategoryVo, FlowCategory> {
}
