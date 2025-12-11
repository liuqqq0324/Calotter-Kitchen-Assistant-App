package com.calotter.cook.domain.vo;

import com.calotter.cook.domain.Session;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T14:29:53+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class SessionVoToSessionMapperImpl implements SessionVoToSessionMapper {

    @Override
    public Session convert(SessionVo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        Session session = new Session();

        session.setId( arg0.getId() );
        session.setUserId( arg0.getUserId() );
        session.setStartTime( arg0.getStartTime() );
        session.setEndTime( arg0.getEndTime() );
        session.setMealType( arg0.getMealType() );
        session.setNote( arg0.getNote() );

        return session;
    }

    @Override
    public Session convert(SessionVo arg0, Session arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setId( arg0.getId() );
        arg1.setUserId( arg0.getUserId() );
        arg1.setStartTime( arg0.getStartTime() );
        arg1.setEndTime( arg0.getEndTime() );
        arg1.setMealType( arg0.getMealType() );
        arg1.setNote( arg0.getNote() );

        return arg1;
    }
}
