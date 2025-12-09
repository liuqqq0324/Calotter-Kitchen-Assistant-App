package org.dromara.system.domain.vo;

import javax.annotation.processing.Generated;
import org.dromara.system.domain.SysOss;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-10T12:23:14+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
public class SysOssVoToSysOssMapperImpl implements SysOssVoToSysOssMapper {

    @Override
    public SysOss convert(SysOssVo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        SysOss sysOss = new SysOss();

        sysOss.setCreateBy( arg0.getCreateBy() );
        sysOss.setCreateTime( arg0.getCreateTime() );
        sysOss.setExt1( arg0.getExt1() );
        sysOss.setFileName( arg0.getFileName() );
        sysOss.setFileSuffix( arg0.getFileSuffix() );
        sysOss.setOriginalName( arg0.getOriginalName() );
        sysOss.setOssId( arg0.getOssId() );
        sysOss.setService( arg0.getService() );
        sysOss.setUrl( arg0.getUrl() );

        return sysOss;
    }

    @Override
    public SysOss convert(SysOssVo arg0, SysOss arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setCreateBy( arg0.getCreateBy() );
        arg1.setCreateTime( arg0.getCreateTime() );
        arg1.setExt1( arg0.getExt1() );
        arg1.setFileName( arg0.getFileName() );
        arg1.setFileSuffix( arg0.getFileSuffix() );
        arg1.setOriginalName( arg0.getOriginalName() );
        arg1.setOssId( arg0.getOssId() );
        arg1.setService( arg0.getService() );
        arg1.setUrl( arg0.getUrl() );

        return arg1;
    }
}
