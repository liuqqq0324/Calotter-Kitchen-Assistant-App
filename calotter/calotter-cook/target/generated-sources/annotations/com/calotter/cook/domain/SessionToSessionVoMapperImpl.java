package com.calotter.cook.domain;

import com.calotter.cook.domain.vo.SessionVo;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T11:32:06+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class SessionToSessionVoMapperImpl implements SessionToSessionVoMapper {

    @Override
    public SessionVo convert(Session arg0) {
        if ( arg0 == null ) {
            return null;
        }

        SessionVo sessionVo = new SessionVo();

        sessionVo.setId( arg0.getId() );
        sessionVo.setUserId( arg0.getUserId() );
        sessionVo.setStartTime( arg0.getStartTime() );
        sessionVo.setEndTime( arg0.getEndTime() );
        sessionVo.setMealType( arg0.getMealType() );
        sessionVo.setNote( arg0.getNote() );

        return sessionVo;
    }

    @Override
    public SessionVo convert(Session arg0, SessionVo arg1) {
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
