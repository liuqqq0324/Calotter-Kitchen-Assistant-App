package com.calotter.user.domain.vo;

import com.calotter.user.domain.Preference;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-10T15:10:17+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class PreferenceVoToPreferenceMapperImpl implements PreferenceVoToPreferenceMapper {

    @Override
    public Preference convert(PreferenceVo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        Preference preference = new Preference();

        preference.setDefaultShown( arg0.getDefaultShown() );
        preference.setDescription( arg0.getDescription() );
        preference.setId( arg0.getId() );
        preference.setName( arg0.getName() );
        preference.setSort( arg0.getSort() );

        return preference;
    }

    @Override
    public Preference convert(PreferenceVo arg0, Preference arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setDefaultShown( arg0.getDefaultShown() );
        arg1.setDescription( arg0.getDescription() );
        arg1.setId( arg0.getId() );
        arg1.setName( arg0.getName() );
        arg1.setSort( arg0.getSort() );

        return arg1;
    }
}
