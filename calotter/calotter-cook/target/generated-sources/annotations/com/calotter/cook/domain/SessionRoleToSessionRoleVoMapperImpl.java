package com.calotter.cook.domain;

import com.calotter.cook.domain.vo.SessionRoleVo;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-10T15:10:11+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class SessionRoleToSessionRoleVoMapperImpl implements SessionRoleToSessionRoleVoMapper {

    @Override
    public SessionRoleVo convert(SessionRole arg0) {
        if ( arg0 == null ) {
            return null;
        }

        SessionRoleVo sessionRoleVo = new SessionRoleVo();

        sessionRoleVo.setFeedbackDesc( arg0.getFeedbackDesc() );
        sessionRoleVo.setFeedbackScore( arg0.getFeedbackScore() );
        sessionRoleVo.setId( arg0.getId() );
        sessionRoleVo.setRoleId( arg0.getRoleId() );
        sessionRoleVo.setSessionId( arg0.getSessionId() );

        return sessionRoleVo;
    }

    @Override
    public SessionRoleVo convert(SessionRole arg0, SessionRoleVo arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setFeedbackDesc( arg0.getFeedbackDesc() );
        arg1.setFeedbackScore( arg0.getFeedbackScore() );
        arg1.setId( arg0.getId() );
        arg1.setRoleId( arg0.getRoleId() );
        arg1.setSessionId( arg0.getSessionId() );

        return arg1;
    }
}
