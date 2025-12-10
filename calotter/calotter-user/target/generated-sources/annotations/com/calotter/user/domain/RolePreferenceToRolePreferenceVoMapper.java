package com.calotter.user.domain;

import com.calotter.user.domain.bo.RolePreferenceBoToRolePreferenceMapper;
import com.calotter.user.domain.vo.RolePreferenceVo;
import com.calotter.user.domain.vo.RolePreferenceVoToRolePreferenceMapper;
import io.github.linpeilie.AutoMapperConfig__52;
import io.github.linpeilie.BaseMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__52.class,
    uses = {RolePreferenceVoToRolePreferenceMapper.class,RolePreferenceBoToRolePreferenceMapper.class},
    imports = {}
)
public interface RolePreferenceToRolePreferenceVoMapper extends BaseMapper<RolePreference, RolePreferenceVo> {
}
