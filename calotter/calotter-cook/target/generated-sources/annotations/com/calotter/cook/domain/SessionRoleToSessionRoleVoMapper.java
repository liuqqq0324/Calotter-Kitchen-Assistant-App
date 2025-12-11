package com.calotter.cook.domain;

import com.calotter.cook.domain.bo.SessionRoleBoToSessionRoleMapper;
import com.calotter.cook.domain.vo.SessionRoleVo;
import com.calotter.cook.domain.vo.SessionRoleVoToSessionRoleMapper;
import io.github.linpeilie.AutoMapperConfig__148;
import io.github.linpeilie.BaseMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__148.class,
    uses = {SessionRoleBoToSessionRoleMapper.class,SessionRoleVoToSessionRoleMapper.class},
    imports = {}
)
public interface SessionRoleToSessionRoleVoMapper extends BaseMapper<SessionRole, SessionRoleVo> {
}
