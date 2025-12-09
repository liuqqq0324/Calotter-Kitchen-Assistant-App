package org.dromara.workflow.domain.vo;

import io.github.linpeilie.AutoMapperConfig__40;
import io.github.linpeilie.BaseMapper;
import org.dromara.workflow.domain.FlowSpel;
import org.dromara.workflow.domain.FlowSpelToFlowSpelVoMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__40.class,
    uses = {FlowSpelToFlowSpelVoMapper.class},
    imports = {}
)
public interface FlowSpelVoToFlowSpelMapper extends BaseMapper<FlowSpelVo, FlowSpel> {
}
