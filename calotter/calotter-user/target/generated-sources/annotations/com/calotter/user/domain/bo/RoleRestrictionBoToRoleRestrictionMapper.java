package com.calotter.user.domain.bo;

import com.calotter.user.domain.RoleRestriction;
import io.github.linpeilie.AutoMapperConfig__151;
import io.github.linpeilie.BaseMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__151.class,
    uses = {},
    imports = {}
)
public interface RoleRestrictionBoToRoleRestrictionMapper extends BaseMapper<RoleRestrictionBo, RoleRestriction> {
}
