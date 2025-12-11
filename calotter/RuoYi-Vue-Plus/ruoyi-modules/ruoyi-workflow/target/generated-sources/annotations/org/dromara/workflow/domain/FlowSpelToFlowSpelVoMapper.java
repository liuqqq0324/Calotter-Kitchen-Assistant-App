package org.dromara.workflow.domain;

import io.github.linpeilie.AutoMapperConfig__138;
import io.github.linpeilie.BaseMapper;
import org.dromara.workflow.domain.bo.FlowSpelBoToFlowSpelMapper;
import org.dromara.workflow.domain.vo.FlowSpelVo;
import org.dromara.workflow.domain.vo.FlowSpelVoToFlowSpelMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__138.class,
    uses = {FlowSpelVoToFlowSpelMapper.class,FlowSpelBoToFlowSpelMapper.class},
    imports = {}
)
public interface FlowSpelToFlowSpelVoMapper extends BaseMapper<FlowSpel, FlowSpelVo> {
}
