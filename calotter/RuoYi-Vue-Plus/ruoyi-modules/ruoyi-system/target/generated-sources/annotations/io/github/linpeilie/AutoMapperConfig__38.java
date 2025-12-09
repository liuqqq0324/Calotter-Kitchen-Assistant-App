package io.github.linpeilie;

import org.dromara.common.log.event.OperLogEventToSysOperLogBoMapper;
import org.dromara.system.domain.SysClientToSysClientVoMapper;
import org.dromara.system.domain.SysConfigToSysConfigVoMapper;
import org.dromara.system.domain.SysDeptToSysDeptVoMapper;
import org.dromara.system.domain.SysDictDataToSysDictDataVoMapper;
import org.dromara.system.domain.SysDictTypeToSysDictTypeVoMapper;
import org.dromara.system.domain.SysLogininforToSysLogininforVoMapper;
import org.dromara.system.domain.SysMenuToSysMenuVoMapper;
import org.dromara.system.domain.SysNoticeToSysNoticeVoMapper;
import org.dromara.system.domain.SysOperLogToSysOperLogVoMapper;
import org.dromara.system.domain.SysOssConfigToSysOssConfigVoMapper;
import org.dromara.system.domain.SysOssToSysOssVoMapper;
import org.dromara.system.domain.SysPostToSysPostVoMapper;
import org.dromara.system.domain.SysRoleToSysRoleVoMapper;
import org.dromara.system.domain.SysSocialToSysSocialVoMapper;
import org.dromara.system.domain.SysTenantPackageToSysTenantPackageVoMapper;
import org.dromara.system.domain.SysTenantToSysTenantVoMapper;
import org.dromara.system.domain.SysUserToSysUserVoMapper;
import org.dromara.system.domain.bo.SysClientBoToSysClientMapper;
import org.dromara.system.domain.bo.SysConfigBoToSysConfigMapper;
import org.dromara.system.domain.bo.SysDeptBoToSysDeptMapper;
import org.dromara.system.domain.bo.SysDictDataBoToSysDictDataMapper;
import org.dromara.system.domain.bo.SysDictTypeBoToSysDictTypeMapper;
import org.dromara.system.domain.bo.SysLogininforBoToSysLogininforMapper;
import org.dromara.system.domain.bo.SysMenuBoToSysMenuMapper;
import org.dromara.system.domain.bo.SysNoticeBoToSysNoticeMapper;
import org.dromara.system.domain.bo.SysOperLogBoToOperLogEventMapper;
import org.dromara.system.domain.bo.SysOperLogBoToSysOperLogMapper;
import org.dromara.system.domain.bo.SysOssBoToSysOssMapper;
import org.dromara.system.domain.bo.SysOssConfigBoToSysOssConfigMapper;
import org.dromara.system.domain.bo.SysPostBoToSysPostMapper;
import org.dromara.system.domain.bo.SysRoleBoToSysRoleMapper;
import org.dromara.system.domain.bo.SysSocialBoToSysSocialMapper;
import org.dromara.system.domain.bo.SysTenantBoToSysTenantMapper;
import org.dromara.system.domain.bo.SysTenantPackageBoToSysTenantPackageMapper;
import org.dromara.system.domain.bo.SysUserBoToSysUserMapper;
import org.dromara.system.domain.vo.SysClientVoToSysClientMapper;
import org.dromara.system.domain.vo.SysConfigVoToSysConfigMapper;
import org.dromara.system.domain.vo.SysDeptVoToSysDeptMapper;
import org.dromara.system.domain.vo.SysDictDataVoToSysDictDataMapper;
import org.dromara.system.domain.vo.SysDictTypeVoToSysDictTypeMapper;
import org.dromara.system.domain.vo.SysLogininforVoToSysLogininforMapper;
import org.dromara.system.domain.vo.SysMenuVoToSysMenuMapper;
import org.dromara.system.domain.vo.SysNoticeVoToSysNoticeMapper;
import org.dromara.system.domain.vo.SysOperLogVoToSysOperLogMapper;
import org.dromara.system.domain.vo.SysOssConfigVoToSysOssConfigMapper;
import org.dromara.system.domain.vo.SysOssVoToSysOssMapper;
import org.dromara.system.domain.vo.SysPostVoToSysPostMapper;
import org.dromara.system.domain.vo.SysRoleVoToSysRoleMapper;
import org.dromara.system.domain.vo.SysSocialVoToSysSocialMapper;
import org.dromara.system.domain.vo.SysTenantPackageVoToSysTenantPackageMapper;
import org.dromara.system.domain.vo.SysTenantVoToSysTenantMapper;
import org.dromara.system.domain.vo.SysUserVoToSysUserMapper;
import org.mapstruct.Builder;
import org.mapstruct.MapperConfig;
import org.mapstruct.ReportingPolicy;

@MapperConfig(
    componentModel = "spring-lazy",
    uses = {ConverterMapperAdapter__38.class, SysDictDataVoToSysDictDataMapper.class, SysLogininforVoToSysLogininforMapper.class, SysConfigBoToSysConfigMapper.class, SysTenantPackageToSysTenantPackageVoMapper.class, SysPostBoToSysPostMapper.class, SysOssConfigVoToSysOssConfigMapper.class, SysDictDataToSysDictDataVoMapper.class, SysRoleVoToSysRoleMapper.class, SysClientVoToSysClientMapper.class, SysOssConfigBoToSysOssConfigMapper.class, SysDeptBoToSysDeptMapper.class, SysOssBoToSysOssMapper.class, SysMenuVoToSysMenuMapper.class, SysClientBoToSysClientMapper.class, SysClientToSysClientVoMapper.class, SysTenantToSysTenantVoMapper.class, SysConfigVoToSysConfigMapper.class, SysSocialBoToSysSocialMapper.class, SysOssVoToSysOssMapper.class, SysDictTypeToSysDictTypeVoMapper.class, SysLogininforToSysLogininforVoMapper.class, SysPostVoToSysPostMapper.class, SysSocialToSysSocialVoMapper.class, SysDictTypeBoToSysDictTypeMapper.class, OperLogEventToSysOperLogBoMapper.class, SysNoticeBoToSysNoticeMapper.class, SysSocialVoToSysSocialMapper.class, SysOssConfigToSysOssConfigVoMapper.class, SysUserToSysUserVoMapper.class, SysDictTypeVoToSysDictTypeMapper.class, SysMenuBoToSysMenuMapper.class, SysConfigToSysConfigVoMapper.class, SysOperLogBoToOperLogEventMapper.class, SysNoticeVoToSysNoticeMapper.class, SysMenuToSysMenuVoMapper.class, SysTenantVoToSysTenantMapper.class, SysUserBoToSysUserMapper.class, SysDictDataBoToSysDictDataMapper.class, SysUserVoToSysUserMapper.class, SysNoticeToSysNoticeVoMapper.class, SysOssToSysOssVoMapper.class, SysOperLogToSysOperLogVoMapper.class, SysLogininforBoToSysLogininforMapper.class, SysDeptVoToSysDeptMapper.class, SysRoleBoToSysRoleMapper.class, SysRoleToSysRoleVoMapper.class, SysTenantPackageVoToSysTenantPackageMapper.class, SysTenantBoToSysTenantMapper.class, SysTenantPackageBoToSysTenantPackageMapper.class, SysOperLogBoToSysOperLogMapper.class, SysOperLogVoToSysOperLogMapper.class, SysDeptToSysDeptVoMapper.class, SysPostToSysPostVoMapper.class},
    unmappedTargetPolicy = ReportingPolicy.IGNORE,
    builder = @Builder(buildMethod = "build", disableBuilder = true)
)
public interface AutoMapperConfig__38 {
}
