package com.calotter.cook.domain.bo;

import com.calotter.cook.domain.SessionRecipe;
import java.util.LinkedHashMap;
import java.util.Map;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-10T15:10:11+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class SessionRecipeBoToSessionRecipeMapperImpl implements SessionRecipeBoToSessionRecipeMapper {

    @Override
    public SessionRecipe convert(SessionRecipeBo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        SessionRecipe sessionRecipe = new SessionRecipe();

        sessionRecipe.setCreateBy( arg0.getCreateBy() );
        sessionRecipe.setCreateDept( arg0.getCreateDept() );
        sessionRecipe.setCreateTime( arg0.getCreateTime() );
        Map<String, Object> map = arg0.getParams();
        if ( map != null ) {
            sessionRecipe.setParams( new LinkedHashMap<String, Object>( map ) );
        }
        sessionRecipe.setSearchValue( arg0.getSearchValue() );
        sessionRecipe.setUpdateBy( arg0.getUpdateBy() );
        sessionRecipe.setUpdateTime( arg0.getUpdateTime() );
        sessionRecipe.setActualDurationMinutes( arg0.getActualDurationMinutes() );
        sessionRecipe.setId( arg0.getId() );
        sessionRecipe.setRecipeId( arg0.getRecipeId() );
        sessionRecipe.setServings( arg0.getServings() );
        sessionRecipe.setSessionId( arg0.getSessionId() );
        sessionRecipe.setSuccessRating( arg0.getSuccessRating() );

        return sessionRecipe;
    }

    @Override
    public SessionRecipe convert(SessionRecipeBo arg0, SessionRecipe arg1) {
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
        arg1.setActualDurationMinutes( arg0.getActualDurationMinutes() );
        arg1.setId( arg0.getId() );
        arg1.setRecipeId( arg0.getRecipeId() );
        arg1.setServings( arg0.getServings() );
        arg1.setSessionId( arg0.getSessionId() );
        arg1.setSuccessRating( arg0.getSuccessRating() );

        return arg1;
    }
}
