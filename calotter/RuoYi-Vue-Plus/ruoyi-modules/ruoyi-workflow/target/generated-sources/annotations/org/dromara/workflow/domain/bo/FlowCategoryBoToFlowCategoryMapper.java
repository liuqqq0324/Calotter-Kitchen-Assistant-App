package org.dromara.workflow.domain.bo;

import io.github.linpeilie.AutoMapperConfig__138;
import io.github.linpeilie.BaseMapper;
import org.dromara.workflow.domain.FlowCategory;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__138.class,
    uses = {},
    imports = {}
)
public interface FlowCategoryBoToFlowCategoryMapper extends BaseMapper<FlowCategoryBo, FlowCategory> {
}
