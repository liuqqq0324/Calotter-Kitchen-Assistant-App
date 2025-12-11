package com.calotter.user.domain.vo;

import com.calotter.user.domain.RoleCuisine;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T14:28:56+1300",
    comments = "version: 1.6.3, compiler: javac, environment: Java 21.0.8 (JetBrains s.r.o.)"
)
@Component
public class RoleCuisineVoToRoleCuisineMapperImpl implements RoleCuisineVoToRoleCuisineMapper {

    @Override
    public RoleCuisine convert(RoleCuisineVo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        RoleCuisine roleCuisine = new RoleCuisine();

        roleCuisine.setId( arg0.getId() );
        roleCuisine.setRoleId( arg0.getRoleId() );
        roleCuisine.setCuisineId( arg0.getCuisineId() );
        roleCuisine.setType( arg0.getType() );
        roleCuisine.setDescription( arg0.getDescription() );

        return roleCuisine;
    }

    @Override
    public RoleCuisine convert(RoleCuisineVo arg0, RoleCuisine arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setId( arg0.getId() );
        arg1.setRoleId( arg0.getRoleId() );
        arg1.setCuisineId( arg0.getCuisineId() );
        arg1.setType( arg0.getType() );
        arg1.setDescription( arg0.getDescription() );

        return arg1;
    }
}
