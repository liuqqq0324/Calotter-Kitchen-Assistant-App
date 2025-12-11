package com.calotter.user.domain;

import com.calotter.user.domain.vo.PreferenceVo;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T14:28:56+1300",
    comments = "version: 1.6.3, compiler: javac, environment: Java 21.0.8 (JetBrains s.r.o.)"
)
@Component
public class PreferenceToPreferenceVoMapperImpl implements PreferenceToPreferenceVoMapper {

    @Override
    public PreferenceVo convert(Preference arg0) {
        if ( arg0 == null ) {
            return null;
        }

        PreferenceVo preferenceVo = new PreferenceVo();

        preferenceVo.setId( arg0.getId() );
        preferenceVo.setName( arg0.getName() );
        preferenceVo.setDescription( arg0.getDescription() );
        preferenceVo.setDefaultShown( arg0.getDefaultShown() );
        preferenceVo.setSort( arg0.getSort() );

        return preferenceVo;
    }

    @Override
    public PreferenceVo convert(Preference arg0, PreferenceVo arg1) {
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
