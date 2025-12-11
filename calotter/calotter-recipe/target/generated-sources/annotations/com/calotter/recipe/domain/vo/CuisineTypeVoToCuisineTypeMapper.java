package com.calotter.recipe.domain.vo;

import com.calotter.recipe.domain.CuisineType;
import com.calotter.recipe.domain.CuisineTypeToCuisineTypeVoMapper;
import io.github.linpeilie.AutoMapperConfig__150;
import io.github.linpeilie.BaseMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__150.class,
    uses = {CuisineTypeToCuisineTypeVoMapper.class},
    imports = {}
)
public interface CuisineTypeVoToCuisineTypeMapper extends BaseMapper<CuisineTypeVo, CuisineType> {
}
