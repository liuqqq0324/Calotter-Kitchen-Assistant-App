package com.calotter.recipe.domain;

import com.calotter.recipe.domain.bo.CuisineTypeBoToCuisineTypeMapper;
import com.calotter.recipe.domain.vo.CuisineTypeVo;
import com.calotter.recipe.domain.vo.CuisineTypeVoToCuisineTypeMapper;
import io.github.linpeilie.AutoMapperConfig__225;
import io.github.linpeilie.BaseMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__225.class,
    uses = {CuisineTypeBoToCuisineTypeMapper.class,CuisineTypeVoToCuisineTypeMapper.class},
    imports = {}
)
public interface CuisineTypeToCuisineTypeVoMapper extends BaseMapper<CuisineType, CuisineTypeVo> {
}
