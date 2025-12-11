package org.dromara.workflow.domain;

import io.github.linpeilie.AutoMapperConfig__115;
import io.github.linpeilie.BaseMapper;
import org.dromara.workflow.domain.bo.FlowSpelBoToFlowSpelMapper__2;
import org.dromara.workflow.domain.vo.FlowSpelVo;
import org.dromara.workflow.domain.vo.FlowSpelVoToFlowSpelMapper__2;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__115.class,
    uses = {FlowSpelVoToFlowSpelMapper__2.class,FlowSpelBoToFlowSpelMapper__2.class},
    imports = {}
)
public interface FlowSpelToFlowSpelVoMapper__2 extends BaseMapper<FlowSpel, FlowSpelVo> {
}
