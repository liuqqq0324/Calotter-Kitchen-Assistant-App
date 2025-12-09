package org.dromara.system.domain.bo;

import java.util.LinkedHashMap;
import java.util.Map;
import javax.annotation.processing.Generated;
import org.dromara.system.domain.SysOssConfig;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-10T12:23:15+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
public class SysOssConfigBoToSysOssConfigMapperImpl implements SysOssConfigBoToSysOssConfigMapper {

    @Override
    public SysOssConfig convert(SysOssConfigBo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        SysOssConfig sysOssConfig = new SysOssConfig();

        sysOssConfig.setCreateBy( arg0.getCreateBy() );
        sysOssConfig.setCreateDept( arg0.getCreateDept() );
        sysOssConfig.setCreateTime( arg0.getCreateTime() );
        Map<String, Object> map = arg0.getParams();
        if ( map != null ) {
            sysOssConfig.setParams( new LinkedHashMap<String, Object>( map ) );
        }
        sysOssConfig.setSearchValue( arg0.getSearchValue() );
        sysOssConfig.setUpdateBy( arg0.getUpdateBy() );
        sysOssConfig.setUpdateTime( arg0.getUpdateTime() );
        sysOssConfig.setAccessKey( arg0.getAccessKey() );
        sysOssConfig.setAccessPolicy( arg0.getAccessPolicy() );
        sysOssConfig.setBucketName( arg0.getBucketName() );
        sysOssConfig.setConfigKey( arg0.getConfigKey() );
        sysOssConfig.setDomain( arg0.getDomain() );
        sysOssConfig.setEndpoint( arg0.getEndpoint() );
        sysOssConfig.setExt1( arg0.getExt1() );
        sysOssConfig.setIsHttps( arg0.getIsHttps() );
        sysOssConfig.setOssConfigId( arg0.getOssConfigId() );
        sysOssConfig.setPrefix( arg0.getPrefix() );
        sysOssConfig.setRegion( arg0.getRegion() );
        sysOssConfig.setRemark( arg0.getRemark() );
        sysOssConfig.setSecretKey( arg0.getSecretKey() );
        sysOssConfig.setStatus( arg0.getStatus() );

        return sysOssConfig;
    }

    @Override
    public SysOssConfig convert(SysOssConfigBo arg0, SysOssConfig arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setCreateBy( arg0.getCreateBy() );
        arg1.setCreateDept( arg0.getCreateDept() );
        arg1.setCreateTime( arg0.getCreateTime() );
        if ( arg1.getParams() != null ) {
            Map<String, Object> map = arg0.getParams();
            if ( map != null ) {
                arg1.getParams().clear();
                arg1.getParams().putAll( map );
            }
            else {
                arg1.setParams( null );
            }
        }
        else {
            Map<String, Object> map = arg0.getParams();
            if ( map != null ) {
                arg1.setParams( new LinkedHashMap<String, Object>( map ) );
            }
        }
        arg1.setSearchValue( arg0.getSearchValue() );
        arg1.setUpdateBy( arg0.getUpdateBy() );
        arg1.setUpdateTime( arg0.getUpdateTime() );
        arg1.setAccessKey( arg0.getAccessKey() );
        arg1.setAccessPolicy( arg0.getAccessPolicy() );
        arg1.setBucketName( arg0.getBucketName() );
        arg1.setConfigKey( arg0.getConfigKey() );
        arg1.setDomain( arg0.getDomain() );
        arg1.setEndpoint( arg0.getEndpoint() );
        arg1.setExt1( arg0.getExt1() );
        arg1.setIsHttps( arg0.getIsHttps() );
        arg1.setOssConfigId( arg0.getOssConfigId() );
        arg1.setPrefix( arg0.getPrefix() );
        arg1.setRegion( arg0.getRegion() );
        arg1.setRemark( arg0.getRemark() );
        arg1.setSecretKey( arg0.getSecretKey() );
        arg1.setStatus( arg0.getStatus() );

        return arg1;
    }
}
