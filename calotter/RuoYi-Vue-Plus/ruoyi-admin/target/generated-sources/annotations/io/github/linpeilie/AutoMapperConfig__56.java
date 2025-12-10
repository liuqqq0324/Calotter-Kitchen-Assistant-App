package io.github.linpeilie;

import org.dromara.common.log.event.OperLogEventToSysOperLogBoMapper;
import org.dromara.common.log.event.OperLogEventToSysOperLogBoMapper__29;
import org.dromara.system.domain.SysClientToSysClientVoMapper__14;
import org.dromara.system.domain.SysConfigToSysConfigVoMapper__14;
import org.dromara.system.domain.SysDeptToSysDeptVoMapper__14;
import org.dromara.system.domain.SysDictDataToSysDictDataVoMapper__14;
import org.dromara.system.domain.SysDictTypeToSysDictTypeVoMapper__14;
import org.dromara.system.domain.SysLogininforToSysLogininforVoMapper__14;
import org.dromara.system.domain.SysMenuToSysMenuVoMapper__14;
import org.dromara.system.domain.SysNoticeToSysNoticeVoMapper__14;
import org.dromara.system.domain.SysOperLogToSysOperLogVoMapper__14;
import org.dromara.system.domain.SysOssConfigToSysOssConfigVoMapper__14;
import org.dromara.system.domain.SysOssToSysOssVoMapper__14;
import org.dromara.system.domain.SysPostToSysPostVoMapper__14;
import org.dromara.system.domain.SysRoleToSysRoleVoMapper__14;
import org.dromara.system.domain.SysSocialToSysSocialVoMapper__14;
import org.dromara.system.domain.SysTenantPackageToSysTenantPackageVoMapper__14;
import org.dromara.system.domain.SysTenantToSysTenantVoMapper__14;
import org.dromara.system.domain.SysUserToSysUserVoMapper__14;
import org.dromara.system.domain.bo.SysClientBoToSysClientMapper__14;
import org.dromara.system.domain.bo.SysConfigBoToSysConfigMapper__14;
import org.dromara.system.domain.bo.SysDeptBoToSysDeptMapper__14;
import org.dromara.system.domain.bo.SysDictDataBoToSysDictDataMapper__14;
import org.dromara.system.domain.bo.SysDictTypeBoToSysDictTypeMapper__14;
import org.dromara.system.domain.bo.SysLogininforBoToSysLogininforMapper__14;
import org.dromara.system.domain.bo.SysMenuBoToSysMenuMapper__14;
import org.dromara.system.domain.bo.SysNoticeBoToSysNoticeMapper__14;
import org.dromara.system.domain.bo.SysOperLogBoToOperLogEventMapper;
import org.dromara.system.domain.bo.SysOperLogBoToOperLogEventMapper__29;
import org.dromara.system.domain.bo.SysOperLogBoToSysOperLogMapper;
import org.dromara.system.domain.bo.SysOperLogBoToSysOperLogMapper__29;
import org.dromara.system.domain.bo.SysOssBoToSysOssMapper__14;
import org.dromara.system.domain.bo.SysOssConfigBoToSysOssConfigMapper__14;
import org.dromara.system.domain.bo.SysPostBoToSysPostMapper__14;
import org.dromara.system.domain.bo.SysRoleBoToSysRoleMapper__14;
import org.dromara.system.domain.bo.SysSocialBoToSysSocialMapper__14;
import org.dromara.system.domain.bo.SysTenantBoToSysTenantMapper__14;
import org.dromara.system.domain.bo.SysTenantPackageBoToSysTenantPackageMapper__14;
import org.dromara.system.domain.bo.SysUserBoToSysUserMapper__14;
import org.dromara.system.domain.vo.SysClientVoToSysClientMapper__14;
import org.dromara.system.domain.vo.SysConfigVoToSysConfigMapper__14;
import org.dromara.system.domain.vo.SysDeptVoToSysDeptMapper__14;
import org.dromara.system.domain.vo.SysDictDataVoToSysDictDataMapper__14;
import org.dromara.system.domain.vo.SysDictTypeVoToSysDictTypeMapper__14;
import org.dromara.system.domain.vo.SysLogininforVoToSysLogininforMapper__14;
import org.dromara.system.domain.vo.SysMenuVoToSysMenuMapper__14;
import org.dromara.system.domain.vo.SysNoticeVoToSysNoticeMapper__14;
import org.dromara.system.domain.vo.SysOperLogVoToSysOperLogMapper__14;
import org.dromara.system.domain.vo.SysOssConfigVoToSysOssConfigMapper__14;
import org.dromara.system.domain.vo.SysOssVoToSysOssMapper__14;
import org.dromara.system.domain.vo.SysPostVoToSysPostMapper__14;
import org.dromara.system.domain.vo.SysRoleVoToSysRoleMapper__14;
import org.dromara.system.domain.vo.SysSocialVoToSysSocialMapper__14;
import org.dromara.system.domain.vo.SysTenantPackageVoToSysTenantPackageMapper__14;
import org.dromara.system.domain.vo.SysTenantVoToSysTenantMapper__14;
import org.dromara.system.domain.vo.SysTenantVoToTenantListVoMapper;
import org.dromara.system.domain.vo.SysTenantVoToTenantListVoMapper__30;
import org.dromara.system.domain.vo.SysUserVoToSysUserMapper__14;
import org.dromara.web.domain.vo.TenantListVoToSysTenantVoMapper;
import org.dromara.web.domain.vo.TenantListVoToSysTenantVoMapper__30;
import org.dromara.workflow.domain.FlowCategoryToFlowCategoryVoMapper;
import org.dromara.workflow.domain.FlowCategoryToFlowCategoryVoMapper__1;
import org.dromara.workflow.domain.FlowSpelToFlowSpelVoMapper;
import org.dromara.workflow.domain.FlowSpelToFlowSpelVoMapper__1;
import org.dromara.workflow.domain.TestLeaveToTestLeaveVoMapper;
import org.dromara.workflow.domain.TestLeaveToTestLeaveVoMapper__1;
import org.dromara.workflow.domain.bo.FlowCategoryBoToFlowCategoryMapper;
import org.dromara.workflow.domain.bo.FlowCategoryBoToFlowCategoryMapper__1;
import org.dromara.workflow.domain.bo.FlowSpelBoToFlowSpelMapper;
import org.dromara.workflow.domain.bo.FlowSpelBoToFlowSpelMapper__1;
import org.dromara.workflow.domain.bo.TestLeaveBoToTestLeaveMapper;
import org.dromara.workflow.domain.bo.TestLeaveBoToTestLeaveMapper__1;
import org.dromara.workflow.domain.vo.FlowCategoryVoToFlowCategoryMapper;
import org.dromara.workflow.domain.vo.FlowCategoryVoToFlowCategoryMapper__1;
import org.dromara.workflow.domain.vo.FlowSpelVoToFlowSpelMapper;
import org.dromara.workflow.domain.vo.FlowSpelVoToFlowSpelMapper__1;
import org.dromara.workflow.domain.vo.TestLeaveVoToTestLeaveMapper;
import org.dromara.workflow.domain.vo.TestLeaveVoToTestLeaveMapper__1;
import org.mapstruct.Builder;
import org.mapstruct.MapperConfig;
import org.mapstruct.ReportingPolicy;

@MapperConfig(
    componentModel = "spring-lazy",
    uses = {ConverterMapperAdapter__56.class, FlowSpelToFlowSpelVoMapper.class, FlowCategoryVoToFlowCategoryMapper__1.class, FlowSpelVoToFlowSpelMapper.class, SysSocialBoToSysSocialMapper__14.class, SysOssVoToSysOssMapper__14.class, SysDeptVoToSysDeptMapper__14.class, SysTenantVoToTenantListVoMapper__30.class, SysClientVoToSysClientMapper__14.class, FlowCategoryToFlowCategoryVoMapper__1.class, SysMenuBoToSysMenuMapper__14.class, SysPostBoToSysPostMapper__14.class, SysClientBoToSysClientMapper__14.class, SysTenantToSysTenantVoMapper__14.class, TestLeaveBoToTestLeaveMapper.class, SysTenantVoToTenantListVoMapper.class, SysOperLogBoToOperLogEventMapper.class, SysUserBoToSysUserMapper__14.class, SysTenantPackageToSysTenantPackageVoMapper__14.class, SysPostToSysPostVoMapper__14.class, FlowSpelBoToFlowSpelMapper__1.class, SysUserVoToSysUserMapper__14.class, FlowCategoryBoToFlowCategoryMapper.class, SysMenuVoToSysMenuMapper__14.class, SysOssBoToSysOssMapper__14.class, SysOssToSysOssVoMapper__14.class, SysDictTypeToSysDictTypeVoMapper__14.class, SysTenantPackageVoToSysTenantPackageMapper__14.class, SysDictDataToSysDictDataVoMapper__14.class, TestLeaveToTestLeaveVoMapper.class, SysConfigToSysConfigVoMapper__14.class, SysLogininforBoToSysLogininforMapper__14.class, SysNoticeToSysNoticeVoMapper__14.class, SysDictDataBoToSysDictDataMapper__14.class, OperLogEventToSysOperLogBoMapper__29.class, TestLeaveVoToTestLeaveMapper__1.class, SysOssConfigToSysOssConfigVoMapper__14.class, TestLeaveVoToTestLeaveMapper.class, TenantListVoToSysTenantVoMapper__30.class, SysLogininforToSysLogininforVoMapper__14.class, SysDictDataVoToSysDictDataMapper__14.class, SysConfigBoToSysConfigMapper__14.class, SysDictTypeBoToSysDictTypeMapper__14.class, SysOperLogToSysOperLogVoMapper__14.class, SysOperLogBoToOperLogEventMapper__29.class, SysRoleVoToSysRoleMapper__14.class, SysOssConfigBoToSysOssConfigMapper__14.class, SysOssConfigVoToSysOssConfigMapper__14.class, SysMenuToSysMenuVoMapper__14.class, FlowCategoryVoToFlowCategoryMapper.class, SysUserToSysUserVoMapper__14.class, SysOperLogBoToSysOperLogMapper__29.class, SysDeptToSysDeptVoMapper__14.class, FlowCategoryBoToFlowCategoryMapper__1.class, SysConfigVoToSysConfigMapper__14.class, SysSocialVoToSysSocialMapper__14.class, SysLogininforVoToSysLogininforMapper__14.class, SysDictTypeVoToSysDictTypeMapper__14.class, SysNoticeVoToSysNoticeMapper__14.class, FlowSpelBoToFlowSpelMapper.class, SysPostVoToSysPostMapper__14.class, SysRoleBoToSysRoleMapper__14.class, SysSocialToSysSocialVoMapper__14.class, SysTenantPackageBoToSysTenantPackageMapper__14.class, TenantListVoToSysTenantVoMapper.class, TestLeaveToTestLeaveVoMapper__1.class, SysTenantVoToSysTenantMapper__14.class, SysRoleToSysRoleVoMapper__14.class, OperLogEventToSysOperLogBoMapper.class, SysDeptBoToSysDeptMapper__14.class, SysOperLogVoToSysOperLogMapper__14.class, SysOperLogBoToSysOperLogMapper.class, FlowSpelToFlowSpelVoMapper__1.class, SysTenantBoToSysTenantMapper__14.class, FlowSpelVoToFlowSpelMapper__1.class, SysClientToSysClientVoMapper__14.class, SysNoticeBoToSysNoticeMapper__14.class, TestLeaveBoToTestLeaveMapper__1.class, FlowCategoryToFlowCategoryVoMapper.class},
    unmappedTargetPolicy = ReportingPolicy.IGNORE,
    builder = @Builder(buildMethod = "build", disableBuilder = true)
)
public interface AutoMapperConfig__56 {
}
