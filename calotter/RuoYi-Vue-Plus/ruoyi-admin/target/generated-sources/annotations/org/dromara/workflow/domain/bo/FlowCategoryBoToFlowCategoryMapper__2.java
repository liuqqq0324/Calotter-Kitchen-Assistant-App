package org.dromara.workflow.domain.bo;

import io.github.linpeilie.AutoMapperConfig__117;
import io.github.linpeilie.BaseMapper;
import org.dromara.workflow.domain.FlowCategory;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__117.class,
    uses = {},
    imports = {}
)
public interface FlowCategoryBoToFlowCategoryMapper__2 extends BaseMapper<FlowCategoryBo, FlowCategory> {
}
