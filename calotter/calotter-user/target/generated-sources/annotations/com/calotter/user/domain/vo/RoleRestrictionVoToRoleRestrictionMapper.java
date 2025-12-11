package com.calotter.user.domain.vo;

import com.calotter.user.domain.RoleRestriction;
import com.calotter.user.domain.RoleRestrictionToRoleRestrictionVoMapper;
import io.github.linpeilie.AutoMapperConfig__226;
import io.github.linpeilie.BaseMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__226.class,
    uses = {RoleRestrictionToRoleRestrictionVoMapper.class},
    imports = {}
)
public interface RoleRestrictionVoToRoleRestrictionMapper extends BaseMapper<RoleRestrictionVo, RoleRestriction> {
}
