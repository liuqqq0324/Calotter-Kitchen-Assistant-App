package org.dromara.workflow.domain.bo;

import io.github.linpeilie.AutoMapperConfig__154;
import io.github.linpeilie.BaseMapper;
import org.dromara.workflow.domain.FlowSpel;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__154.class,
    uses = {},
    imports = {}
)
public interface FlowSpelBoToFlowSpelMapper extends BaseMapper<FlowSpelBo, FlowSpel> {
}
