package com.calotter.cook.domain.bo;

import com.calotter.cook.domain.SessionRole;
import java.util.LinkedHashMap;
import java.util.Map;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T14:29:53+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class SessionRoleBoToSessionRoleMapperImpl implements SessionRoleBoToSessionRoleMapper {

    @Override
    public SessionRole convert(SessionRoleBo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        SessionRole sessionRole = new SessionRole();

        sessionRole.setCreateBy( arg0.getCreateBy() );
        sessionRole.setCreateDept( arg0.getCreateDept() );
        sessionRole.setCreateTime( arg0.getCreateTime() );
        Map<String, Object> map = arg0.getParams();
        if ( map != null ) {
            sessionRole.setParams( new LinkedHashMap<String, Object>( map ) );
        }
        sessionRole.setSearchValue( arg0.getSearchValue() );
        sessionRole.setUpdateBy( arg0.getUpdateBy() );
        sessionRole.setUpdateTime( arg0.getUpdateTime() );
        sessionRole.setId( arg0.getId() );
        sessionRole.setSessionId( arg0.getSessionId() );
        sessionRole.setRoleId( arg0.getRoleId() );
        sessionRole.setFeedbackScore( arg0.getFeedbackScore() );
        sessionRole.setFeedbackDesc( arg0.getFeedbackDesc() );

        return sessionRole;
    }

    @Override
    public SessionRole convert(SessionRoleBo arg0, SessionRole arg1) {
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
        arg1.setId( arg0.getId() );
        arg1.setSessionId( arg0.getSessionId() );
        arg1.setRoleId( arg0.getRoleId() );
        arg1.setFeedbackScore( arg0.getFeedbackScore() );
        arg1.setFeedbackDesc( arg0.getFeedbackDesc() );

        return arg1;
    }
}
