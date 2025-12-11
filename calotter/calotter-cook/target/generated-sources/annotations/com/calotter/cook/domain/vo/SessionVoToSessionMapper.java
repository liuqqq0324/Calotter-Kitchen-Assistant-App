package com.calotter.cook.domain.vo;

import com.calotter.cook.domain.Session;
import com.calotter.cook.domain.SessionToSessionVoMapper;
import io.github.linpeilie.AutoMapperConfig__129;
import io.github.linpeilie.BaseMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__129.class,
    uses = {SessionToSessionVoMapper.class},
    imports = {}
)
public interface SessionVoToSessionMapper extends BaseMapper<SessionVo, Session> {
}
