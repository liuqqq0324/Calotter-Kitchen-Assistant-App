package org.dromara.workflow.domain.vo;

import io.github.linpeilie.AutoMapperConfig__39;
import io.github.linpeilie.BaseMapper;
import org.dromara.workflow.domain.FlowSpel;
import org.dromara.workflow.domain.FlowSpelToFlowSpelVoMapper__1;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__39.class,
    uses = {FlowSpelToFlowSpelVoMapper__1.class},
    imports = {}
)
public interface FlowSpelVoToFlowSpelMapper__1 extends BaseMapper<FlowSpelVo, FlowSpel> {
}
