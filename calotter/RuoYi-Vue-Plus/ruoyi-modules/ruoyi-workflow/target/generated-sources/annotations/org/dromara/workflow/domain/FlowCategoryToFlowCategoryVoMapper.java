package org.dromara.workflow.domain;

import io.github.linpeilie.AutoMapperConfig__154;
import io.github.linpeilie.BaseMapper;
import org.dromara.workflow.domain.bo.FlowCategoryBoToFlowCategoryMapper;
import org.dromara.workflow.domain.vo.FlowCategoryVo;
import org.dromara.workflow.domain.vo.FlowCategoryVoToFlowCategoryMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__154.class,
    uses = {FlowCategoryVoToFlowCategoryMapper.class,FlowCategoryBoToFlowCategoryMapper.class},
    imports = {}
)
public interface FlowCategoryToFlowCategoryVoMapper extends BaseMapper<FlowCategory, FlowCategoryVo> {
}
