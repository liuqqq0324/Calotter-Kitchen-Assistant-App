package org.dromara.workflow.domain.vo;

import io.github.linpeilie.AutoMapperConfig__39;
import io.github.linpeilie.BaseMapper;
import org.dromara.workflow.domain.FlowSpel;
import org.dromara.workflow.domain.FlowSpelToFlowSpelVoMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__39.class,
    uses = {FlowSpelToFlowSpelVoMapper.class},
    imports = {}
)
public interface FlowSpelVoToFlowSpelMapper extends BaseMapper<FlowSpelVo, FlowSpel> {
}
