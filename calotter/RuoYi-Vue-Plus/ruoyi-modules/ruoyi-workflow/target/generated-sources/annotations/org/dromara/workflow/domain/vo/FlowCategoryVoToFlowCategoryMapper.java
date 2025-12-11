package org.dromara.workflow.domain.vo;

<<<<<<< HEAD
import io.github.linpeilie.AutoMapperConfig__55;
=======
import io.github.linpeilie.AutoMapperConfig__14;
>>>>>>> chase/flutter-v1-android-java
import io.github.linpeilie.BaseMapper;
import org.dromara.workflow.domain.FlowCategory;
import org.dromara.workflow.domain.FlowCategoryToFlowCategoryVoMapper;
import org.mapstruct.Mapper;

@Mapper(
<<<<<<< HEAD
    config = AutoMapperConfig__55.class,
=======
    config = AutoMapperConfig__14.class,
>>>>>>> chase/flutter-v1-android-java
    uses = {FlowCategoryToFlowCategoryVoMapper.class},
    imports = {}
)
public interface FlowCategoryVoToFlowCategoryMapper extends BaseMapper<FlowCategoryVo, FlowCategory> {
}
