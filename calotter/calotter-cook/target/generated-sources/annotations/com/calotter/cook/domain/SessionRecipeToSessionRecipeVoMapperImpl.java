package com.calotter.cook.domain;

import com.calotter.cook.domain.vo.SessionRecipeVo;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T11:32:07+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class SessionRecipeToSessionRecipeVoMapperImpl implements SessionRecipeToSessionRecipeVoMapper {

    @Override
    public SessionRecipeVo convert(SessionRecipe arg0) {
        if ( arg0 == null ) {
            return null;
        }

        SessionRecipeVo sessionRecipeVo = new SessionRecipeVo();

        sessionRecipeVo.setId( arg0.getId() );
        sessionRecipeVo.setSessionId( arg0.getSessionId() );
        sessionRecipeVo.setRecipeId( arg0.getRecipeId() );
        sessionRecipeVo.setServings( arg0.getServings() );
        sessionRecipeVo.setActualDurationMinutes( arg0.getActualDurationMinutes() );
        sessionRecipeVo.setSuccessRating( arg0.getSuccessRating() );

        return sessionRecipeVo;
    }

    @Override
    public SessionRecipeVo convert(SessionRecipe arg0, SessionRecipeVo arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setId( arg0.getId() );
        arg1.setSessionId( arg0.getSessionId() );
        arg1.setRecipeId( arg0.getRecipeId() );
        arg1.setServings( arg0.getServings() );
        arg1.setActualDurationMinutes( arg0.getActualDurationMinutes() );
        arg1.setSuccessRating( arg0.getSuccessRating() );

        return arg1;
    }
}
