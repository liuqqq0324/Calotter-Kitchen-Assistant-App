package com.calotter.cook.domain.bo;

import com.calotter.cook.domain.Session;
import io.github.linpeilie.AutoMapperConfig__148;
import io.github.linpeilie.BaseMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__148.class,
    uses = {},
    imports = {}
)
public interface SessionBoToSessionMapper extends BaseMapper<SessionBo, Session> {
}
