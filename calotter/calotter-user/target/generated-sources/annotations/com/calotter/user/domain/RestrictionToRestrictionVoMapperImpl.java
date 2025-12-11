package com.calotter.user.domain;

import com.calotter.user.domain.vo.RestrictionVo;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T13:57:48+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class RestrictionToRestrictionVoMapperImpl implements RestrictionToRestrictionVoMapper {

    @Override
    public RestrictionVo convert(Restriction arg0) {
        if ( arg0 == null ) {
            return null;
        }

        RestrictionVo restrictionVo = new RestrictionVo();

        restrictionVo.setDefaultShown( arg0.getDefaultShown() );
        restrictionVo.setDescription( arg0.getDescription() );
        restrictionVo.setId( arg0.getId() );
        restrictionVo.setName( arg0.getName() );
        restrictionVo.setSort( arg0.getSort() );

        return restrictionVo;
    }

    @Override
    public RestrictionVo convert(Restriction arg0, RestrictionVo arg1) {
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
