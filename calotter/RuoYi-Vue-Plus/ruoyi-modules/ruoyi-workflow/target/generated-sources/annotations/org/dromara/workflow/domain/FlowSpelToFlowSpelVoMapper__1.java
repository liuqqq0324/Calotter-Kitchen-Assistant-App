package org.dromara.workflow.domain;

import io.github.linpeilie.AutoMapperConfig__39;
import io.github.linpeilie.BaseMapper;
import org.dromara.workflow.domain.bo.FlowSpelBoToFlowSpelMapper__1;
import org.dromara.workflow.domain.vo.FlowSpelVo;
import org.dromara.workflow.domain.vo.FlowSpelVoToFlowSpelMapper__1;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__39.class,
    uses = {FlowSpelVoToFlowSpelMapper__1.class,FlowSpelBoToFlowSpelMapper__1.class},
    imports = {}
)
public interface FlowSpelToFlowSpelVoMapper__1 extends BaseMapper<FlowSpel, FlowSpelVo> {
}
