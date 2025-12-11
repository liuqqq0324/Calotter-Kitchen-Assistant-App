package org.dromara.system.domain.bo;

import javax.annotation.processing.Generated;
import org.dromara.system.domain.SysOperLog;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T13:58:00+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class SysOperLogBoToSysOperLogMapper__3Impl implements SysOperLogBoToSysOperLogMapper__3 {

    @Override
    public SysOperLog convert(SysOperLogBo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        SysOperLog sysOperLog = new SysOperLog();

        sysOperLog.setBusinessType( arg0.getBusinessType() );
        sysOperLog.setCostTime( arg0.getCostTime() );
        sysOperLog.setDeptName( arg0.getDeptName() );
        sysOperLog.setErrorMsg( arg0.getErrorMsg() );
        sysOperLog.setJsonResult( arg0.getJsonResult() );
        sysOperLog.setMethod( arg0.getMethod() );
        sysOperLog.setOperId( arg0.getOperId() );
        sysOperLog.setOperIp( arg0.getOperIp() );
        sysOperLog.setOperLocation( arg0.getOperLocation() );
        sysOperLog.setOperName( arg0.getOperName() );
        sysOperLog.setOperParam( arg0.getOperParam() );
        sysOperLog.setOperTime( arg0.getOperTime() );
        sysOperLog.setOperUrl( arg0.getOperUrl() );
        sysOperLog.setOperatorType( arg0.getOperatorType() );
        sysOperLog.setRequestMethod( arg0.getRequestMethod() );
        sysOperLog.setStatus( arg0.getStatus() );
        sysOperLog.setTenantId( arg0.getTenantId() );
        sysOperLog.setTitle( arg0.getTitle() );

        return sysOperLog;
    }

    @Override
    public SysOperLog convert(SysOperLogBo arg0, SysOperLog arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setBusinessType( arg0.getBusinessType() );
        arg1.setCostTime( arg0.getCostTime() );
        arg1.setDeptName( arg0.getDeptName() );
        arg1.setErrorMsg( arg0.getErrorMsg() );
        arg1.setJsonResult( arg0.getJsonResult() );
        arg1.setMethod( arg0.getMethod() );
        arg1.setOperId( arg0.getOperId() );
        arg1.setOperIp( arg0.getOperIp() );
        arg1.setOperLocation( arg0.getOperLocation() );
        arg1.setOperName( arg0.getOperName() );
        arg1.setOperParam( arg0.getOperParam() );
        arg1.setOperTime( arg0.getOperTime() );
        arg1.setOperUrl( arg0.getOperUrl() );
        arg1.setOperatorType( arg0.getOperatorType() );
        arg1.setRequestMethod( arg0.getRequestMethod() );
        arg1.setStatus( arg0.getStatus() );
        arg1.setTenantId( arg0.getTenantId() );
        arg1.setTitle( arg0.getTitle() );

        return arg1;
    }
}
