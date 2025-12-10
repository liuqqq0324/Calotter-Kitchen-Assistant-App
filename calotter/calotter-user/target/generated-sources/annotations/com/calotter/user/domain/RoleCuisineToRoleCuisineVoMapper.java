package com.calotter.user.domain;

import com.calotter.user.domain.bo.RoleCuisineBoToRoleCuisineMapper;
import com.calotter.user.domain.vo.RoleCuisineVo;
import com.calotter.user.domain.vo.RoleCuisineVoToRoleCuisineMapper;
import io.github.linpeilie.AutoMapperConfig__52;
import io.github.linpeilie.BaseMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__52.class,
    uses = {RoleCuisineBoToRoleCuisineMapper.class,RoleCuisineVoToRoleCuisineMapper.class},
    imports = {}
)
public interface RoleCuisineToRoleCuisineVoMapper extends BaseMapper<RoleCuisine, RoleCuisineVo> {
}
