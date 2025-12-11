package org.dromara.workflow.domain;

<<<<<<< HEAD
import io.github.linpeilie.AutoMapperConfig__55;
=======
import io.github.linpeilie.AutoMapperConfig__14;
>>>>>>> chase/flutter-v1-android-java
import io.github.linpeilie.BaseMapper;
import org.dromara.workflow.domain.bo.TestLeaveBoToTestLeaveMapper;
import org.dromara.workflow.domain.vo.TestLeaveVo;
import org.dromara.workflow.domain.vo.TestLeaveVoToTestLeaveMapper;
import org.mapstruct.Mapper;

@Mapper(
<<<<<<< HEAD
    config = AutoMapperConfig__55.class,
=======
    config = AutoMapperConfig__14.class,
>>>>>>> chase/flutter-v1-android-java
    uses = {TestLeaveVoToTestLeaveMapper.class,TestLeaveBoToTestLeaveMapper.class},
    imports = {}
)
public interface TestLeaveToTestLeaveVoMapper extends BaseMapper<TestLeave, TestLeaveVo> {
}
