package org.dromara.workflow.domain.vo;

import io.github.linpeilie.AutoMapperConfig__115;
import io.github.linpeilie.BaseMapper;
import org.dromara.workflow.domain.FlowSpel;
import org.dromara.workflow.domain.FlowSpelToFlowSpelVoMapper__2;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__115.class,
    uses = {FlowSpelToFlowSpelVoMapper__2.class},
    imports = {}
)
public interface FlowSpelVoToFlowSpelMapper__2 extends BaseMapper<FlowSpelVo, FlowSpel> {
}
