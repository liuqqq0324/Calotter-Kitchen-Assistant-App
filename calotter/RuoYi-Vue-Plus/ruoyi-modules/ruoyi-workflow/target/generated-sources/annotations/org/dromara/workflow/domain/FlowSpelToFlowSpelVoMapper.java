package org.dromara.workflow.domain;

<<<<<<< HEAD
import io.github.linpeilie.AutoMapperConfig__55;
=======
import io.github.linpeilie.AutoMapperConfig__14;
>>>>>>> chase/flutter-v1-android-java
import io.github.linpeilie.BaseMapper;
import org.dromara.workflow.domain.bo.FlowSpelBoToFlowSpelMapper;
import org.dromara.workflow.domain.vo.FlowSpelVo;
import org.dromara.workflow.domain.vo.FlowSpelVoToFlowSpelMapper;
import org.mapstruct.Mapper;

@Mapper(
<<<<<<< HEAD
    config = AutoMapperConfig__55.class,
=======
    config = AutoMapperConfig__14.class,
>>>>>>> chase/flutter-v1-android-java
    uses = {FlowSpelVoToFlowSpelMapper.class,FlowSpelBoToFlowSpelMapper.class},
    imports = {}
)
public interface FlowSpelToFlowSpelVoMapper extends BaseMapper<FlowSpel, FlowSpelVo> {
}
