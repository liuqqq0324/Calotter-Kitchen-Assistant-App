package org.dromara.workflow.domain.vo;

<<<<<<< HEAD
import io.github.linpeilie.AutoMapperConfig__55;
=======
import io.github.linpeilie.AutoMapperConfig__14;
>>>>>>> chase/flutter-v1-android-java
import io.github.linpeilie.BaseMapper;
import org.dromara.workflow.domain.FlowSpel;
import org.dromara.workflow.domain.FlowSpelToFlowSpelVoMapper;
import org.mapstruct.Mapper;

@Mapper(
<<<<<<< HEAD
    config = AutoMapperConfig__55.class,
=======
    config = AutoMapperConfig__14.class,
>>>>>>> chase/flutter-v1-android-java
    uses = {FlowSpelToFlowSpelVoMapper.class},
    imports = {}
)
public interface FlowSpelVoToFlowSpelMapper extends BaseMapper<FlowSpelVo, FlowSpel> {
}
