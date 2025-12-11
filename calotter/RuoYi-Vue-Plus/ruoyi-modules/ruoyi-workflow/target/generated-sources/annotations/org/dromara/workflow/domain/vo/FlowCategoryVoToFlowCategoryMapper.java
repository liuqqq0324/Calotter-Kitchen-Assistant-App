package org.dromara.workflow.domain.vo;

import io.github.linpeilie.AutoMapperConfig__154;
import io.github.linpeilie.BaseMapper;
import org.dromara.workflow.domain.FlowCategory;
import org.dromara.workflow.domain.FlowCategoryToFlowCategoryVoMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__154.class,
    uses = {FlowCategoryToFlowCategoryVoMapper.class},
    imports = {}
)
public interface FlowCategoryVoToFlowCategoryMapper extends BaseMapper<FlowCategoryVo, FlowCategory> {
}
