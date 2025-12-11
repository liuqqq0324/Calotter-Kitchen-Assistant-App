package com.calotter.user.domain.bo;

import com.calotter.user.domain.Preference;
import java.util.LinkedHashMap;
import java.util.Map;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T14:28:56+1300",
    comments = "version: 1.6.3, compiler: javac, environment: Java 21.0.8 (JetBrains s.r.o.)"
)
@Component
public class PreferenceBoToPreferenceMapperImpl implements PreferenceBoToPreferenceMapper {

    @Override
    public Preference convert(PreferenceBo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        Preference preference = new Preference();

        preference.setSearchValue( arg0.getSearchValue() );
        preference.setCreateDept( arg0.getCreateDept() );
        preference.setCreateBy( arg0.getCreateBy() );
        preference.setCreateTime( arg0.getCreateTime() );
        preference.setUpdateBy( arg0.getUpdateBy() );
        preference.setUpdateTime( arg0.getUpdateTime() );
        Map<String, Object> map = arg0.getParams();
        if ( map != null ) {
            preference.setParams( new LinkedHashMap<String, Object>( map ) );
        }
        preference.setId( arg0.getId() );
        preference.setName( arg0.getName() );
        preference.setDescription( arg0.getDescription() );
        preference.setDefaultShown( arg0.getDefaultShown() );
        preference.setSort( arg0.getSort() );

        return preference;
    }

    @Override
    public Preference convert(PreferenceBo arg0, Preference arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setSearchValue( arg0.getSearchValue() );
        arg1.setCreateDept( arg0.getCreateDept() );
        arg1.setCreateBy( arg0.getCreateBy() );
        arg1.setCreateTime( arg0.getCreateTime() );
        arg1.setUpdateBy( arg0.getUpdateBy() );
        arg1.setUpdateTime( arg0.getUpdateTime() );
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
        arg1.setId( arg0.getId() );
        arg1.setName( arg0.getName() );
        arg1.setDescription( arg0.getDescription() );
        arg1.setDefaultShown( arg0.getDefaultShown() );
        arg1.setSort( arg0.getSort() );

        return arg1;
    }
}
