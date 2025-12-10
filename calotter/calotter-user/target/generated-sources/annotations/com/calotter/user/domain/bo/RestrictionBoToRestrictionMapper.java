package com.calotter.user.domain.bo;

import com.calotter.user.domain.Restriction;
import io.github.linpeilie.AutoMapperConfig__52;
import io.github.linpeilie.BaseMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__52.class,
    uses = {},
    imports = {}
)
public interface RestrictionBoToRestrictionMapper extends BaseMapper<RestrictionBo, Restriction> {
}
