package com.calotter.cook.domain.bo;

import com.calotter.cook.domain.Session;
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
public class SessionBoToSessionMapperImpl implements SessionBoToSessionMapper {

    @Override
    public Session convert(SessionBo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        Session session = new Session();

        session.setCreateBy( arg0.getCreateBy() );
        session.setCreateDept( arg0.getCreateDept() );
        session.setCreateTime( arg0.getCreateTime() );
        Map<String, Object> map = arg0.getParams();
        if ( map != null ) {
            session.setParams( new LinkedHashMap<String, Object>( map ) );
        }
        session.setSearchValue( arg0.getSearchValue() );
        session.setUpdateBy( arg0.getUpdateBy() );
        session.setUpdateTime( arg0.getUpdateTime() );
        session.setId( arg0.getId() );
        session.setUserId( arg0.getUserId() );
        session.setStartTime( arg0.getStartTime() );
        session.setEndTime( arg0.getEndTime() );
        session.setMealType( arg0.getMealType() );
        session.setNote( arg0.getNote() );

        return session;
    }

    @Override
    public Session convert(SessionBo arg0, Session arg1) {
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
        arg1.setUserId( arg0.getUserId() );
        arg1.setStartTime( arg0.getStartTime() );
        arg1.setEndTime( arg0.getEndTime() );
        arg1.setMealType( arg0.getMealType() );
        arg1.setNote( arg0.getNote() );

        return arg1;
    }
}
