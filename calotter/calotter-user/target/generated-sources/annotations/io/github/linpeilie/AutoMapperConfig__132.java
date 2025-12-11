package io.github.linpeilie;

import com.calotter.user.domain.PreferenceToPreferenceVoMapper;
import com.calotter.user.domain.RestrictionToRestrictionVoMapper;
import com.calotter.user.domain.RoleCuisineToRoleCuisineVoMapper;
import com.calotter.user.domain.RoleLogToRoleLogVoMapper;
import com.calotter.user.domain.RolePreferenceToRolePreferenceVoMapper;
import com.calotter.user.domain.RoleRestrictionToRoleRestrictionVoMapper;
import com.calotter.user.domain.UserRoleToUserRoleVoMapper;
import com.calotter.user.domain.UserToUserVoMapper;
import com.calotter.user.domain.bo.PreferenceBoToPreferenceMapper;
import com.calotter.user.domain.bo.RestrictionBoToRestrictionMapper;
import com.calotter.user.domain.bo.RoleCuisineBoToRoleCuisineMapper;
import com.calotter.user.domain.bo.RoleLogBoToRoleLogMapper;
import com.calotter.user.domain.bo.RolePreferenceBoToRolePreferenceMapper;
import com.calotter.user.domain.bo.RoleRestrictionBoToRoleRestrictionMapper;
import com.calotter.user.domain.bo.UserBoToUserMapper;
import com.calotter.user.domain.bo.UserRoleBoToUserRoleMapper;
import com.calotter.user.domain.vo.PreferenceVoToPreferenceMapper;
import com.calotter.user.domain.vo.RestrictionVoToRestrictionMapper;
import com.calotter.user.domain.vo.RoleCuisineVoToRoleCuisineMapper;
import com.calotter.user.domain.vo.RoleLogVoToRoleLogMapper;
import com.calotter.user.domain.vo.RolePreferenceVoToRolePreferenceMapper;
import com.calotter.user.domain.vo.RoleRestrictionVoToRoleRestrictionMapper;
import com.calotter.user.domain.vo.UserRoleVoToUserRoleMapper;
import com.calotter.user.domain.vo.UserVoToUserMapper;
import org.mapstruct.Builder;
import org.mapstruct.MapperConfig;
import org.mapstruct.ReportingPolicy;

@MapperConfig(
    componentModel = "spring-lazy",
    uses = {ConverterMapperAdapter__132.class, RoleRestrictionBoToRoleRestrictionMapper.class, RoleCuisineVoToRoleCuisineMapper.class, RoleLogBoToRoleLogMapper.class, UserToUserVoMapper.class, RoleLogToRoleLogVoMapper.class, RoleCuisineBoToRoleCuisineMapper.class, PreferenceVoToPreferenceMapper.class, PreferenceBoToPreferenceMapper.class, RoleRestrictionVoToRoleRestrictionMapper.class, RolePreferenceToRolePreferenceVoMapper.class, PreferenceToPreferenceVoMapper.class, RoleCuisineToRoleCuisineVoMapper.class, RoleRestrictionToRoleRestrictionVoMapper.class, RestrictionVoToRestrictionMapper.class, RestrictionToRestrictionVoMapper.class, RolePreferenceVoToRolePreferenceMapper.class, RolePreferenceBoToRolePreferenceMapper.class, UserRoleBoToUserRoleMapper.class, RestrictionBoToRestrictionMapper.class, UserBoToUserMapper.class, RoleLogVoToRoleLogMapper.class, UserRoleVoToUserRoleMapper.class, UserRoleToUserRoleVoMapper.class, UserVoToUserMapper.class},
    unmappedTargetPolicy = ReportingPolicy.IGNORE,
    builder = @Builder(buildMethod = "build", disableBuilder = true)
)
public interface AutoMapperConfig__132 {
}
