package org.dromara.common.log.event;

import java.util.Arrays;
import javax.annotation.processing.Generated;
import org.dromara.system.domain.bo.SysOperLogBo;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-10T12:08:16+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class OperLogEventToSysOperLogBoMapperImpl implements OperLogEventToSysOperLogBoMapper {

    @Override
    public SysOperLogBo convert(OperLogEvent arg0) {
        if ( arg0 == null ) {
            return null;
        }

        SysOperLogBo sysOperLogBo = new SysOperLogBo();

        sysOperLogBo.setOperId( arg0.getOperId() );
        sysOperLogBo.setTenantId( arg0.getTenantId() );
        sysOperLogBo.setTitle( arg0.getTitle() );
        sysOperLogBo.setBusinessType( arg0.getBusinessType() );
        Integer[] businessTypes = arg0.getBusinessTypes();
        if ( businessTypes != null ) {
            sysOperLogBo.setBusinessTypes( Arrays.copyOf( businessTypes, businessTypes.length ) );
        }
        sysOperLogBo.setMethod( arg0.getMethod() );
        sysOperLogBo.setRequestMethod( arg0.getRequestMethod() );
        sysOperLogBo.setOperatorType( arg0.getOperatorType() );
        sysOperLogBo.setOperName( arg0.getOperName() );
        sysOperLogBo.setDeptName( arg0.getDeptName() );
        sysOperLogBo.setOperUrl( arg0.getOperUrl() );
        sysOperLogBo.setOperIp( arg0.getOperIp() );
        sysOperLogBo.setOperLocation( arg0.getOperLocation() );
        sysOperLogBo.setOperParam( arg0.getOperParam() );
        sysOperLogBo.setJsonResult( arg0.getJsonResult() );
        sysOperLogBo.setStatus( arg0.getStatus() );
        sysOperLogBo.setErrorMsg( arg0.getErrorMsg() );
        sysOperLogBo.setOperTime( arg0.getOperTime() );
        sysOperLogBo.setCostTime( arg0.getCostTime() );

        return sysOperLogBo;
    }

    @Override
    public SysOperLogBo convert(OperLogEvent arg0, SysOperLogBo arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setOperId( arg0.getOperId() );
        arg1.setTenantId( arg0.getTenantId() );
        arg1.setTitle( arg0.getTitle() );
        arg1.setBusinessType( arg0.getBusinessType() );
        Integer[] businessTypes = arg0.getBusinessTypes();
        if ( businessTypes != null ) {
            arg1.setBusinessTypes( Arrays.copyOf( businessTypes, businessTypes.length ) );
        }
        else {
            arg1.setBusinessTypes( null );
        }
        arg1.setMethod( arg0.getMethod() );
        arg1.setRequestMethod( arg0.getRequestMethod() );
        arg1.setOperatorType( arg0.getOperatorType() );
        arg1.setOperName( arg0.getOperName() );
        arg1.setDeptName( arg0.getDeptName() );
        arg1.setOperUrl( arg0.getOperUrl() );
        arg1.setOperIp( arg0.getOperIp() );
        arg1.setOperLocation( arg0.getOperLocation() );
        arg1.setOperParam( arg0.getOperParam() );
        arg1.setJsonResult( arg0.getJsonResult() );
        arg1.setStatus( arg0.getStatus() );
        arg1.setErrorMsg( arg0.getErrorMsg() );
        arg1.setOperTime( arg0.getOperTime() );
        arg1.setCostTime( arg0.getCostTime() );

        return arg1;
    }
}
