package com.calotter.user.domain.bo;

import com.calotter.user.domain.Preference;
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
public class PreferenceBoToPreferenceMapperImpl implements PreferenceBoToPreferenceMapper {

    @Override
    public Preference convert(PreferenceBo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        Preference preference = new Preference();

        preference.setCreateBy( arg0.getCreateBy() );
        preference.setCreateDept( arg0.getCreateDept() );
        preference.setCreateTime( arg0.getCreateTime() );
        Map<String, Object> map = arg0.getParams();
        if ( map != null ) {
            preference.setParams( new LinkedHashMap<String, Object>( map ) );
        }
        preference.setSearchValue( arg0.getSearchValue() );
        preference.setUpdateBy( arg0.getUpdateBy() );
        preference.setUpdateTime( arg0.getUpdateTime() );
        preference.setDefaultShown( arg0.getDefaultShown() );
        preference.setDescription( arg0.getDescription() );
        preference.setId( arg0.getId() );
        preference.setName( arg0.getName() );
        preference.setSort( arg0.getSort() );

        return preference;
    }

    @Override
    public Preference convert(PreferenceBo arg0, Preference arg1) {
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
