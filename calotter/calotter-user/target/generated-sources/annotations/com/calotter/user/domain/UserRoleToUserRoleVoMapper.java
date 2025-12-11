package com.calotter.user.domain;

import com.calotter.user.domain.bo.UserRoleBoToUserRoleMapper;
import com.calotter.user.domain.vo.UserRoleVo;
import com.calotter.user.domain.vo.UserRoleVoToUserRoleMapper;
import io.github.linpeilie.AutoMapperConfig__151;
import io.github.linpeilie.BaseMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__151.class,
    uses = {UserRoleVoToUserRoleMapper.class,UserRoleBoToUserRoleMapper.class},
    imports = {}
)
public interface UserRoleToUserRoleVoMapper extends BaseMapper<UserRole, UserRoleVo> {
}
