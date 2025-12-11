package com.calotter.user.domain.vo;

import com.calotter.user.domain.Restriction;
import com.calotter.user.domain.RestrictionToRestrictionVoMapper;
import io.github.linpeilie.AutoMapperConfig__132;
import io.github.linpeilie.BaseMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__132.class,
    uses = {RestrictionToRestrictionVoMapper.class},
    imports = {}
)
public interface RestrictionVoToRestrictionMapper extends BaseMapper<RestrictionVo, Restriction> {
}
