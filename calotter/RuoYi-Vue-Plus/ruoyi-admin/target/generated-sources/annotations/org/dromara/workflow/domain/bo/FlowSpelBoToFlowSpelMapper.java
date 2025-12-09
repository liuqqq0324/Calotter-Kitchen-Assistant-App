package org.dromara.workflow.domain.bo;

import io.github.linpeilie.AutoMapperConfig__40;
import io.github.linpeilie.BaseMapper;
import org.dromara.workflow.domain.FlowSpel;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__40.class,
    uses = {},
    imports = {}
)
public interface FlowSpelBoToFlowSpelMapper extends BaseMapper<FlowSpelBo, FlowSpel> {
}
