package com.calotter.cook.domain;

import com.calotter.cook.domain.bo.SessionBoToSessionMapper;
import com.calotter.cook.domain.vo.SessionVo;
import com.calotter.cook.domain.vo.SessionVoToSessionMapper;
import io.github.linpeilie.AutoMapperConfig__148;
import io.github.linpeilie.BaseMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__148.class,
    uses = {SessionVoToSessionMapper.class,SessionBoToSessionMapper.class},
    imports = {}
)
public interface SessionToSessionVoMapper extends BaseMapper<Session, SessionVo> {
}
