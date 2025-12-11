package org.dromara.system.domain.vo;

import javax.annotation.processing.Generated;
import org.dromara.system.domain.SysOssConfig;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
<<<<<<< HEAD
    date = "2025-12-10T15:10:34+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
=======
    date = "2025-12-10T13:27:23+1300",
    comments = "version: 1.6.3, compiler: javac, environment: Java 25.0.1 (Homebrew)"
>>>>>>> chase/flutter-v1-android-java
)
@Component
public class SysOssConfigVoToSysOssConfigMapperImpl implements SysOssConfigVoToSysOssConfigMapper {

    @Override
    public SysOssConfig convert(SysOssConfigVo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        SysOssConfig sysOssConfig = new SysOssConfig();

        sysOssConfig.setOssConfigId( arg0.getOssConfigId() );
        sysOssConfig.setConfigKey( arg0.getConfigKey() );
        sysOssConfig.setAccessKey( arg0.getAccessKey() );
        sysOssConfig.setSecretKey( arg0.getSecretKey() );
        sysOssConfig.setBucketName( arg0.getBucketName() );
        sysOssConfig.setPrefix( arg0.getPrefix() );
        sysOssConfig.setEndpoint( arg0.getEndpoint() );
        sysOssConfig.setDomain( arg0.getDomain() );
        sysOssConfig.setIsHttps( arg0.getIsHttps() );
        sysOssConfig.setRegion( arg0.getRegion() );
        sysOssConfig.setStatus( arg0.getStatus() );
        sysOssConfig.setExt1( arg0.getExt1() );
        sysOssConfig.setRemark( arg0.getRemark() );
        sysOssConfig.setAccessPolicy( arg0.getAccessPolicy() );

        return sysOssConfig;
    }

    @Override
    public SysOssConfig convert(SysOssConfigVo arg0, SysOssConfig arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setOssConfigId( arg0.getOssConfigId() );
        arg1.setConfigKey( arg0.getConfigKey() );
        arg1.setAccessKey( arg0.getAccessKey() );
        arg1.setSecretKey( arg0.getSecretKey() );
        arg1.setBucketName( arg0.getBucketName() );
        arg1.setPrefix( arg0.getPrefix() );
        arg1.setEndpoint( arg0.getEndpoint() );
        arg1.setDomain( arg0.getDomain() );
        arg1.setIsHttps( arg0.getIsHttps() );
        arg1.setRegion( arg0.getRegion() );
        arg1.setStatus( arg0.getStatus() );
        arg1.setExt1( arg0.getExt1() );
        arg1.setRemark( arg0.getRemark() );
        arg1.setAccessPolicy( arg0.getAccessPolicy() );

        return arg1;
    }
}
