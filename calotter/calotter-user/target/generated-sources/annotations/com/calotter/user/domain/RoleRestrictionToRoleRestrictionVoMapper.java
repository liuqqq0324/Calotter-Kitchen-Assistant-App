package com.calotter.user.domain;

import com.calotter.user.domain.bo.RoleRestrictionBoToRoleRestrictionMapper;
import com.calotter.user.domain.vo.RoleRestrictionVo;
import com.calotter.user.domain.vo.RoleRestrictionVoToRoleRestrictionMapper;
import io.github.linpeilie.AutoMapperConfig__132;
import io.github.linpeilie.BaseMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__132.class,
    uses = {RoleRestrictionBoToRoleRestrictionMapper.class,RoleRestrictionVoToRoleRestrictionMapper.class},
    imports = {}
)
public interface RoleRestrictionToRoleRestrictionVoMapper extends BaseMapper<RoleRestriction, RoleRestrictionVo> {
}
