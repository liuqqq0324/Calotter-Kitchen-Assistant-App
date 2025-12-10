package com.calotter.user.domain.bo;

import com.calotter.user.domain.Restriction;
import java.util.LinkedHashMap;
import java.util.Map;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-10T15:10:17+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class RestrictionBoToRestrictionMapperImpl implements RestrictionBoToRestrictionMapper {

    @Override
    public Restriction convert(RestrictionBo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        Restriction restriction = new Restriction();

        restriction.setCreateBy( arg0.getCreateBy() );
        restriction.setCreateDept( arg0.getCreateDept() );
        restriction.setCreateTime( arg0.getCreateTime() );
        Map<String, Object> map = arg0.getParams();
        if ( map != null ) {
            restriction.setParams( new LinkedHashMap<String, Object>( map ) );
        }
        restriction.setSearchValue( arg0.getSearchValue() );
        restriction.setUpdateBy( arg0.getUpdateBy() );
        restriction.setUpdateTime( arg0.getUpdateTime() );
        restriction.setDefaultShown( arg0.getDefaultShown() );
        restriction.setDescription( arg0.getDescription() );
        restriction.setId( arg0.getId() );
        restriction.setName( arg0.getName() );
        restriction.setSort( arg0.getSort() );

        return restriction;
    }

    @Override
    public Restriction convert(RestrictionBo arg0, Restriction arg1) {
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
        arg1.setDefaultShown( arg0.getDefaultShown() );
        arg1.setDescription( arg0.getDescription() );
        arg1.setId( arg0.getId() );
        arg1.setName( arg0.getName() );
        arg1.setSort( arg0.getSort() );

        return arg1;
    }
}
