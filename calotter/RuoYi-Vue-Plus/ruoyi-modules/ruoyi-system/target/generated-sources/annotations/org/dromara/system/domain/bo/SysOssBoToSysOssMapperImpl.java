package org.dromara.system.domain.bo;

import java.util.LinkedHashMap;
import java.util.Map;
import javax.annotation.processing.Generated;
import org.dromara.system.domain.SysOss;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
<<<<<<< HEAD
    date = "2025-12-10T15:10:36+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
=======
    date = "2025-12-10T13:27:23+1300",
    comments = "version: 1.6.3, compiler: javac, environment: Java 25.0.1 (Homebrew)"
>>>>>>> chase/flutter-v1-android-java
)
@Component
public class SysOssBoToSysOssMapperImpl implements SysOssBoToSysOssMapper {

    @Override
    public SysOss convert(SysOssBo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        SysOss sysOss = new SysOss();

        sysOss.setSearchValue( arg0.getSearchValue() );
        sysOss.setCreateDept( arg0.getCreateDept() );
        sysOss.setCreateBy( arg0.getCreateBy() );
        sysOss.setCreateTime( arg0.getCreateTime() );
        sysOss.setUpdateBy( arg0.getUpdateBy() );
        sysOss.setUpdateTime( arg0.getUpdateTime() );
        Map<String, Object> map = arg0.getParams();
        if ( map != null ) {
            sysOss.setParams( new LinkedHashMap<String, Object>( map ) );
        }
        sysOss.setOssId( arg0.getOssId() );
        sysOss.setFileName( arg0.getFileName() );
        sysOss.setOriginalName( arg0.getOriginalName() );
        sysOss.setFileSuffix( arg0.getFileSuffix() );
        sysOss.setUrl( arg0.getUrl() );
        sysOss.setExt1( arg0.getExt1() );
        sysOss.setService( arg0.getService() );

        return sysOss;
    }

    @Override
    public SysOss convert(SysOssBo arg0, SysOss arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setSearchValue( arg0.getSearchValue() );
        arg1.setCreateDept( arg0.getCreateDept() );
        arg1.setCreateBy( arg0.getCreateBy() );
        arg1.setCreateTime( arg0.getCreateTime() );
        arg1.setUpdateBy( arg0.getUpdateBy() );
        arg1.setUpdateTime( arg0.getUpdateTime() );
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
        arg1.setOssId( arg0.getOssId() );
        arg1.setFileName( arg0.getFileName() );
        arg1.setOriginalName( arg0.getOriginalName() );
        arg1.setFileSuffix( arg0.getFileSuffix() );
        arg1.setUrl( arg0.getUrl() );
        arg1.setExt1( arg0.getExt1() );
        arg1.setService( arg0.getService() );

        return arg1;
    }
}
