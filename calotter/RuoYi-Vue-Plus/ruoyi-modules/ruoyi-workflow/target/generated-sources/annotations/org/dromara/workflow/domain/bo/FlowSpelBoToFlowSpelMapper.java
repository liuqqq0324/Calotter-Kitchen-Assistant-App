package org.dromara.workflow.domain.bo;

import io.github.linpeilie.AutoMapperConfig__55;
import io.github.linpeilie.BaseMapper;
import org.dromara.workflow.domain.FlowSpel;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__55.class,
    uses = {},
    imports = {}
)
public interface FlowSpelBoToFlowSpelMapper extends BaseMapper<FlowSpelBo, FlowSpel> {
}
