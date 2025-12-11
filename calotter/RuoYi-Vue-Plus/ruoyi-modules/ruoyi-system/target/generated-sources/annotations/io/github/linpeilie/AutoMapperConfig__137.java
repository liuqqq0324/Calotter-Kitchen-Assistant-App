package io.github.linpeilie;

import org.dromara.common.log.event.OperLogEventToSysOperLogBoMapper__3;
import org.dromara.system.domain.SysClientToSysClientVoMapper__3;
import org.dromara.system.domain.SysConfigToSysConfigVoMapper__3;
import org.dromara.system.domain.SysDeptToSysDeptVoMapper__3;
import org.dromara.system.domain.SysDictDataToSysDictDataVoMapper__3;
import org.dromara.system.domain.SysDictTypeToSysDictTypeVoMapper__3;
import org.dromara.system.domain.SysLogininforToSysLogininforVoMapper__3;
import org.dromara.system.domain.SysMenuToSysMenuVoMapper__3;
import org.dromara.system.domain.SysNoticeToSysNoticeVoMapper__3;
import org.dromara.system.domain.SysOperLogToSysOperLogVoMapper__3;
import org.dromara.system.domain.SysOssConfigToSysOssConfigVoMapper__3;
import org.dromara.system.domain.SysOssToSysOssVoMapper__3;
import org.dromara.system.domain.SysPostToSysPostVoMapper__3;
import org.dromara.system.domain.SysRoleToSysRoleVoMapper__3;
import org.dromara.system.domain.SysSocialToSysSocialVoMapper__3;
import org.dromara.system.domain.SysTenantPackageToSysTenantPackageVoMapper__3;
import org.dromara.system.domain.SysTenantToSysTenantVoMapper__3;
import org.dromara.system.domain.SysUserToSysUserVoMapper__3;
import org.dromara.system.domain.bo.SysClientBoToSysClientMapper__3;
import org.dromara.system.domain.bo.SysConfigBoToSysConfigMapper__3;
import org.dromara.system.domain.bo.SysDeptBoToSysDeptMapper__3;
import org.dromara.system.domain.bo.SysDictDataBoToSysDictDataMapper__3;
import org.dromara.system.domain.bo.SysDictTypeBoToSysDictTypeMapper__3;
import org.dromara.system.domain.bo.SysLogininforBoToSysLogininforMapper__3;
import org.dromara.system.domain.bo.SysMenuBoToSysMenuMapper__3;
import org.dromara.system.domain.bo.SysNoticeBoToSysNoticeMapper__3;
import org.dromara.system.domain.bo.SysOperLogBoToOperLogEventMapper__3;
import org.dromara.system.domain.bo.SysOperLogBoToSysOperLogMapper__3;
import org.dromara.system.domain.bo.SysOssBoToSysOssMapper__3;
import org.dromara.system.domain.bo.SysOssConfigBoToSysOssConfigMapper__3;
import org.dromara.system.domain.bo.SysPostBoToSysPostMapper__3;
import org.dromara.system.domain.bo.SysRoleBoToSysRoleMapper__3;
import org.dromara.system.domain.bo.SysSocialBoToSysSocialMapper__3;
import org.dromara.system.domain.bo.SysTenantBoToSysTenantMapper__3;
import org.dromara.system.domain.bo.SysTenantPackageBoToSysTenantPackageMapper__3;
import org.dromara.system.domain.bo.SysUserBoToSysUserMapper__3;
import org.dromara.system.domain.vo.SysClientVoToSysClientMapper__3;
import org.dromara.system.domain.vo.SysConfigVoToSysConfigMapper__3;
import org.dromara.system.domain.vo.SysDeptVoToSysDeptMapper__3;
import org.dromara.system.domain.vo.SysDictDataVoToSysDictDataMapper__3;
import org.dromara.system.domain.vo.SysDictTypeVoToSysDictTypeMapper__3;
import org.dromara.system.domain.vo.SysLogininforVoToSysLogininforMapper__3;
import org.dromara.system.domain.vo.SysMenuVoToSysMenuMapper__3;
import org.dromara.system.domain.vo.SysNoticeVoToSysNoticeMapper__3;
import org.dromara.system.domain.vo.SysOperLogVoToSysOperLogMapper__3;
import org.dromara.system.domain.vo.SysOssConfigVoToSysOssConfigMapper__3;
import org.dromara.system.domain.vo.SysOssVoToSysOssMapper__3;
import org.dromara.system.domain.vo.SysPostVoToSysPostMapper__3;
import org.dromara.system.domain.vo.SysRoleVoToSysRoleMapper__3;
import org.dromara.system.domain.vo.SysSocialVoToSysSocialMapper__3;
import org.dromara.system.domain.vo.SysTenantPackageVoToSysTenantPackageMapper__3;
import org.dromara.system.domain.vo.SysTenantVoToSysTenantMapper__3;
import org.dromara.system.domain.vo.SysUserVoToSysUserMapper__3;
import org.mapstruct.Builder;
import org.mapstruct.MapperConfig;
import org.mapstruct.ReportingPolicy;

@MapperConfig(
    componentModel = "spring-lazy",
    uses = {ConverterMapperAdapter__137.class, SysDictTypeToSysDictTypeVoMapper__3.class, SysTenantVoToSysTenantMapper__3.class, SysLogininforToSysLogininforVoMapper__3.class, SysConfigBoToSysConfigMapper__3.class, SysConfigVoToSysConfigMapper__3.class, SysDeptBoToSysDeptMapper__3.class, SysClientVoToSysClientMapper__3.class, SysOssConfigToSysOssConfigVoMapper__3.class, SysDeptToSysDeptVoMapper__3.class, SysDictDataVoToSysDictDataMapper__3.class, SysDictDataBoToSysDictDataMapper__3.class, SysOssConfigBoToSysOssConfigMapper__3.class, SysNoticeToSysNoticeVoMapper__3.class, SysMenuVoToSysMenuMapper__3.class, SysPostVoToSysPostMapper__3.class, SysOperLogBoToOperLogEventMapper__3.class, SysLogininforVoToSysLogininforMapper__3.class, SysSocialToSysSocialVoMapper__3.class, SysDeptVoToSysDeptMapper__3.class, SysTenantPackageVoToSysTenantPackageMapper__3.class, SysPostBoToSysPostMapper__3.class, SysLogininforBoToSysLogininforMapper__3.class, SysOssToSysOssVoMapper__3.class, SysRoleBoToSysRoleMapper__3.class, SysOperLogBoToSysOperLogMapper__3.class, SysClientToSysClientVoMapper__3.class, SysDictTypeBoToSysDictTypeMapper__3.class, SysNoticeBoToSysNoticeMapper__3.class, SysSocialVoToSysSocialMapper__3.class, SysRoleToSysRoleVoMapper__3.class, SysOssConfigVoToSysOssConfigMapper__3.class, SysSocialBoToSysSocialMapper__3.class, SysUserToSysUserVoMapper__3.class, SysOssVoToSysOssMapper__3.class, SysOperLogToSysOperLogVoMapper__3.class, SysTenantToSysTenantVoMapper__3.class, SysMenuBoToSysMenuMapper__3.class, SysOssBoToSysOssMapper__3.class, SysDictTypeVoToSysDictTypeMapper__3.class, SysRoleVoToSysRoleMapper__3.class, SysDictDataToSysDictDataVoMapper__3.class, SysTenantPackageToSysTenantPackageVoMapper__3.class, SysTenantPackageBoToSysTenantPackageMapper__3.class, SysConfigToSysConfigVoMapper__3.class, OperLogEventToSysOperLogBoMapper__3.class, SysMenuToSysMenuVoMapper__3.class, SysTenantBoToSysTenantMapper__3.class, SysOperLogVoToSysOperLogMapper__3.class, SysUserBoToSysUserMapper__3.class, SysNoticeVoToSysNoticeMapper__3.class, SysClientBoToSysClientMapper__3.class, SysUserVoToSysUserMapper__3.class, SysPostToSysPostVoMapper__3.class},
    unmappedTargetPolicy = ReportingPolicy.IGNORE,
    builder = @Builder(buildMethod = "build", disableBuilder = true)
)
public interface AutoMapperConfig__137 {
}
