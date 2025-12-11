package com.calotter.user.domain.vo;

import com.calotter.user.domain.RoleCuisine;
import com.calotter.user.domain.RoleCuisineToRoleCuisineVoMapper;
import io.github.linpeilie.AutoMapperConfig__151;
import io.github.linpeilie.BaseMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__151.class,
    uses = {RoleCuisineToRoleCuisineVoMapper.class},
    imports = {}
)
public interface RoleCuisineVoToRoleCuisineMapper extends BaseMapper<RoleCuisineVo, RoleCuisine> {
}
