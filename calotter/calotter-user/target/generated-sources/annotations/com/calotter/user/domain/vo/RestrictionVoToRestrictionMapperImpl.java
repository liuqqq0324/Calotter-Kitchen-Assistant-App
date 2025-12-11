package com.calotter.user.domain.vo;

import com.calotter.user.domain.Restriction;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T14:28:56+1300",
    comments = "version: 1.6.3, compiler: javac, environment: Java 21.0.8 (JetBrains s.r.o.)"
)
@Component
public class RestrictionVoToRestrictionMapperImpl implements RestrictionVoToRestrictionMapper {

    @Override
    public Restriction convert(RestrictionVo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        Restriction restriction = new Restriction();

        restriction.setId( arg0.getId() );
        restriction.setName( arg0.getName() );
        restriction.setDescription( arg0.getDescription() );
        restriction.setDefaultShown( arg0.getDefaultShown() );
        restriction.setSort( arg0.getSort() );

        return restriction;
    }

    @Override
    public Restriction convert(RestrictionVo arg0, Restriction arg1) {
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
