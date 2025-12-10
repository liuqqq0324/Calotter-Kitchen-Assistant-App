package com.calotter.user.domain.vo;

import com.calotter.user.domain.User;
import com.calotter.user.domain.UserToUserVoMapper;
import io.github.linpeilie.AutoMapperConfig__52;
import io.github.linpeilie.BaseMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__52.class,
    uses = {UserToUserVoMapper.class},
    imports = {}
)
public interface UserVoToUserMapper extends BaseMapper<UserVo, User> {
}
