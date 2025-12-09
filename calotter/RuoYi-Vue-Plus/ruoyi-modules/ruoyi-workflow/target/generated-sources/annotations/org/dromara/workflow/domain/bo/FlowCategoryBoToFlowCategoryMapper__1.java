package org.dromara.workflow.domain.bo;

import io.github.linpeilie.AutoMapperConfig__39;
import io.github.linpeilie.BaseMapper;
import org.dromara.workflow.domain.FlowCategory;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__39.class,
    uses = {},
    imports = {}
)
public interface FlowCategoryBoToFlowCategoryMapper__1 extends BaseMapper<FlowCategoryBo, FlowCategory> {
}
