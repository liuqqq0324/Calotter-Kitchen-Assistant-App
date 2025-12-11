package com.calotter.cook.domain.vo;

import com.calotter.cook.domain.SessionRole;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T11:32:06+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class SessionRoleVoToSessionRoleMapperImpl implements SessionRoleVoToSessionRoleMapper {

    @Override
    public SessionRole convert(SessionRoleVo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        SessionRole sessionRole = new SessionRole();

        sessionRole.setId( arg0.getId() );
        sessionRole.setSessionId( arg0.getSessionId() );
        sessionRole.setRoleId( arg0.getRoleId() );
        sessionRole.setFeedbackScore( arg0.getFeedbackScore() );
        sessionRole.setFeedbackDesc( arg0.getFeedbackDesc() );

        return sessionRole;
    }

    @Override
    public SessionRole convert(SessionRoleVo arg0, SessionRole arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setId( arg0.getId() );
        arg1.setSessionId( arg0.getSessionId() );
        arg1.setRoleId( arg0.getRoleId() );
        arg1.setFeedbackScore( arg0.getFeedbackScore() );
        arg1.setFeedbackDesc( arg0.getFeedbackDesc() );

        return arg1;
    }
}
