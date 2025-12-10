package com.calotter.user.domain.bo;

import com.calotter.user.domain.RoleRestriction;
import io.github.linpeilie.AutoMapperConfig__52;
import io.github.linpeilie.BaseMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__52.class,
    uses = {},
    imports = {}
)
public interface RoleRestrictionBoToRoleRestrictionMapper extends BaseMapper<RoleRestrictionBo, RoleRestriction> {
}
