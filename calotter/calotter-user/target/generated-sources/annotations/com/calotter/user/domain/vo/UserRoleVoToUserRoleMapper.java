package com.calotter.user.domain.vo;

import com.calotter.user.domain.UserRole;
import com.calotter.user.domain.UserRoleToUserRoleVoMapper;
import io.github.linpeilie.AutoMapperConfig__226;
import io.github.linpeilie.BaseMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__226.class,
    uses = {UserRoleToUserRoleVoMapper.class},
    imports = {}
)
public interface UserRoleVoToUserRoleMapper extends BaseMapper<UserRoleVo, UserRole> {
}
