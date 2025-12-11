package com.calotter.cook.domain.bo;

import com.calotter.cook.domain.SessionRole;
import io.github.linpeilie.AutoMapperConfig__129;
import io.github.linpeilie.BaseMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__129.class,
    uses = {},
    imports = {}
)
public interface SessionRoleBoToSessionRoleMapper extends BaseMapper<SessionRoleBo, SessionRole> {
}
