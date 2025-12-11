package org.dromara.workflow.domain.bo;

import io.github.linpeilie.AutoMapperConfig__115;
import io.github.linpeilie.BaseMapper;
import org.dromara.workflow.domain.FlowCategory;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__115.class,
    uses = {},
    imports = {}
)
public interface FlowCategoryBoToFlowCategoryMapper__2 extends BaseMapper<FlowCategoryBo, FlowCategory> {
}
