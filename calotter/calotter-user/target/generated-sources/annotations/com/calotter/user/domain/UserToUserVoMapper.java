package com.calotter.user.domain;

import com.calotter.user.domain.bo.UserBoToUserMapper;
import com.calotter.user.domain.vo.UserVo;
import com.calotter.user.domain.vo.UserVoToUserMapper;
import io.github.linpeilie.AutoMapperConfig__151;
import io.github.linpeilie.BaseMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__151.class,
    uses = {UserVoToUserMapper.class,UserBoToUserMapper.class},
    imports = {}
)
public interface UserToUserVoMapper extends BaseMapper<User, UserVo> {
}
