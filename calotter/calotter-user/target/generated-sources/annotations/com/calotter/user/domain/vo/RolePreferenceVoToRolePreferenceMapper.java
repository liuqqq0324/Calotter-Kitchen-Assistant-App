package com.calotter.user.domain.vo;

import com.calotter.user.domain.RolePreference;
import com.calotter.user.domain.RolePreferenceToRolePreferenceVoMapper;
import io.github.linpeilie.AutoMapperConfig__226;
import io.github.linpeilie.BaseMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__226.class,
    uses = {RolePreferenceToRolePreferenceVoMapper.class},
    imports = {}
)
public interface RolePreferenceVoToRolePreferenceMapper extends BaseMapper<RolePreferenceVo, RolePreference> {
}
