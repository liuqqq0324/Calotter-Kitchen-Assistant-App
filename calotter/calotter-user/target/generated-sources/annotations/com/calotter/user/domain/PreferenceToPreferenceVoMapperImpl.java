package com.calotter.user.domain;

import com.calotter.user.domain.vo.PreferenceVo;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-10T15:10:17+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class PreferenceToPreferenceVoMapperImpl implements PreferenceToPreferenceVoMapper {

    @Override
    public PreferenceVo convert(Preference arg0) {
        if ( arg0 == null ) {
            return null;
        }

        PreferenceVo preferenceVo = new PreferenceVo();

        preferenceVo.setDefaultShown( arg0.getDefaultShown() );
        preferenceVo.setDescription( arg0.getDescription() );
        preferenceVo.setId( arg0.getId() );
        preferenceVo.setName( arg0.getName() );
        preferenceVo.setSort( arg0.getSort() );

        return preferenceVo;
    }

    @Override
    public PreferenceVo convert(Preference arg0, PreferenceVo arg1) {
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
