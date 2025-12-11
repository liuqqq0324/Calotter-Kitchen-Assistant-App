package com.calotter.user.domain.vo;

import com.calotter.user.domain.RoleCuisine;
import com.calotter.user.domain.RoleCuisineToRoleCuisineVoMapper;
import io.github.linpeilie.AutoMapperConfig__226;
import io.github.linpeilie.BaseMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__226.class,
    uses = {RoleCuisineToRoleCuisineVoMapper.class},
    imports = {}
)
public interface RoleCuisineVoToRoleCuisineMapper extends BaseMapper<RoleCuisineVo, RoleCuisine> {
}
