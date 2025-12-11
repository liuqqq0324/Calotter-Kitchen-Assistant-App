package com.calotter.user.domain;

import com.calotter.user.domain.bo.RolePreferenceBoToRolePreferenceMapper;
import com.calotter.user.domain.vo.RolePreferenceVo;
import com.calotter.user.domain.vo.RolePreferenceVoToRolePreferenceMapper;
import io.github.linpeilie.AutoMapperConfig__132;
import io.github.linpeilie.BaseMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__132.class,
    uses = {RolePreferenceVoToRolePreferenceMapper.class,RolePreferenceBoToRolePreferenceMapper.class},
    imports = {}
)
public interface RolePreferenceToRolePreferenceVoMapper extends BaseMapper<RolePreference, RolePreferenceVo> {
}
