package com.calotter.user.domain.vo;

import com.calotter.user.domain.Preference;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T14:28:56+1300",
    comments = "version: 1.6.3, compiler: javac, environment: Java 21.0.8 (JetBrains s.r.o.)"
)
@Component
public class PreferenceVoToPreferenceMapperImpl implements PreferenceVoToPreferenceMapper {

    @Override
    public Preference convert(PreferenceVo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        Preference preference = new Preference();

        preference.setId( arg0.getId() );
        preference.setName( arg0.getName() );
        preference.setDescription( arg0.getDescription() );
        preference.setDefaultShown( arg0.getDefaultShown() );
        preference.setSort( arg0.getSort() );

        return preference;
    }

    @Override
    public Preference convert(PreferenceVo arg0, Preference arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setId( arg0.getId() );
        arg1.setName( arg0.getName() );
        arg1.setDescription( arg0.getDescription() );
        arg1.setDefaultShown( arg0.getDefaultShown() );
        arg1.setSort( arg0.getSort() );

        return arg1;
    }
}
