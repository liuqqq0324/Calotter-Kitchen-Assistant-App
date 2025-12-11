package com.calotter.user.domain;

import com.calotter.user.domain.vo.RoleCuisineVo;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T14:28:56+1300",
    comments = "version: 1.6.3, compiler: javac, environment: Java 21.0.8 (JetBrains s.r.o.)"
)
@Component
public class RoleCuisineToRoleCuisineVoMapperImpl implements RoleCuisineToRoleCuisineVoMapper {

    @Override
    public RoleCuisineVo convert(RoleCuisine arg0) {
        if ( arg0 == null ) {
            return null;
        }

        RoleCuisineVo roleCuisineVo = new RoleCuisineVo();

        roleCuisineVo.setId( arg0.getId() );
        roleCuisineVo.setRoleId( arg0.getRoleId() );
        roleCuisineVo.setCuisineId( arg0.getCuisineId() );
        roleCuisineVo.setType( arg0.getType() );
        roleCuisineVo.setDescription( arg0.getDescription() );

        return roleCuisineVo;
    }

    @Override
    public RoleCuisineVo convert(RoleCuisine arg0, RoleCuisineVo arg1) {
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
