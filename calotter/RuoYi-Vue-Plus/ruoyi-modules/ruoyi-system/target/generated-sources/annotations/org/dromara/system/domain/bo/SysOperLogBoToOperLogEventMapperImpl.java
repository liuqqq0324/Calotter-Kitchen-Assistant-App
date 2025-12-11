package org.dromara.system.domain.bo;

import java.util.Arrays;
import javax.annotation.processing.Generated;
import org.dromara.common.log.event.OperLogEvent;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
<<<<<<< HEAD
    date = "2025-12-10T15:10:37+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
=======
    date = "2025-12-10T13:27:23+1300",
    comments = "version: 1.6.3, compiler: javac, environment: Java 25.0.1 (Homebrew)"
>>>>>>> chase/flutter-v1-android-java
)
@Component
public class SysOperLogBoToOperLogEventMapperImpl implements SysOperLogBoToOperLogEventMapper {

    @Override
    public OperLogEvent convert(SysOperLogBo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        OperLogEvent operLogEvent = new OperLogEvent();

        operLogEvent.setOperId( arg0.getOperId() );
        operLogEvent.setTenantId( arg0.getTenantId() );
        operLogEvent.setTitle( arg0.getTitle() );
        operLogEvent.setBusinessType( arg0.getBusinessType() );
        Integer[] businessTypes = arg0.getBusinessTypes();
        if ( businessTypes != null ) {
            operLogEvent.setBusinessTypes( Arrays.copyOf( businessTypes, businessTypes.length ) );
        }
        operLogEvent.setMethod( arg0.getMethod() );
        operLogEvent.setRequestMethod( arg0.getRequestMethod() );
        operLogEvent.setOperatorType( arg0.getOperatorType() );
        operLogEvent.setOperName( arg0.getOperName() );
        operLogEvent.setDeptName( arg0.getDeptName() );
        operLogEvent.setOperUrl( arg0.getOperUrl() );
        operLogEvent.setOperIp( arg0.getOperIp() );
        operLogEvent.setOperLocation( arg0.getOperLocation() );
        operLogEvent.setOperParam( arg0.getOperParam() );
        operLogEvent.setJsonResult( arg0.getJsonResult() );
        operLogEvent.setStatus( arg0.getStatus() );
        operLogEvent.setErrorMsg( arg0.getErrorMsg() );
        operLogEvent.setOperTime( arg0.getOperTime() );
        operLogEvent.setCostTime( arg0.getCostTime() );

        return operLogEvent;
    }

    @Override
    public OperLogEvent convert(SysOperLogBo arg0, OperLogEvent arg1) {
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
