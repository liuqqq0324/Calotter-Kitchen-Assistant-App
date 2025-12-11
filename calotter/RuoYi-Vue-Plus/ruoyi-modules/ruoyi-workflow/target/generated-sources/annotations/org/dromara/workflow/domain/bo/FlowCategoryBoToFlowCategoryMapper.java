package org.dromara.workflow.domain.bo;

import io.github.linpeilie.AutoMapperConfig__37;
import io.github.linpeilie.BaseMapper;
import org.dromara.workflow.domain.FlowCategory;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__37.class,
    uses = {},
    imports = {}
)
public interface FlowCategoryBoToFlowCategoryMapper extends BaseMapper<FlowCategoryBo, FlowCategory> {
}
