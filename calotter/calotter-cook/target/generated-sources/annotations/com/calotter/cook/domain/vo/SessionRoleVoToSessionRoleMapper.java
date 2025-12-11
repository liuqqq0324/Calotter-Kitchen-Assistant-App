package com.calotter.cook.domain.vo;

import com.calotter.cook.domain.SessionRole;
import com.calotter.cook.domain.SessionRoleToSessionRoleVoMapper;
import io.github.linpeilie.AutoMapperConfig__148;
import io.github.linpeilie.BaseMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__148.class,
    uses = {SessionRoleToSessionRoleVoMapper.class},
    imports = {}
)
public interface SessionRoleVoToSessionRoleMapper extends BaseMapper<SessionRoleVo, SessionRole> {
}
