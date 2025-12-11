package org.dromara.workflow.domain.vo;

import io.github.linpeilie.AutoMapperConfig__138;
import io.github.linpeilie.BaseMapper;
import org.dromara.workflow.domain.FlowCategory;
import org.dromara.workflow.domain.FlowCategoryToFlowCategoryVoMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__138.class,
    uses = {FlowCategoryToFlowCategoryVoMapper.class},
    imports = {}
)
public interface FlowCategoryVoToFlowCategoryMapper extends BaseMapper<FlowCategoryVo, FlowCategory> {
}
