package com.calotter.user.domain.bo;

import com.calotter.user.domain.RolePreference;
import io.github.linpeilie.AutoMapperConfig__132;
import io.github.linpeilie.BaseMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__132.class,
    uses = {},
    imports = {}
)
public interface RolePreferenceBoToRolePreferenceMapper extends BaseMapper<RolePreferenceBo, RolePreference> {
}
