package com.calotter.user.domain;

import com.calotter.user.domain.vo.RoleCuisineVo;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T13:57:48+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class RoleCuisineToRoleCuisineVoMapperImpl implements RoleCuisineToRoleCuisineVoMapper {

    @Override
    public RoleCuisineVo convert(RoleCuisine arg0) {
        if ( arg0 == null ) {
            return null;
        }

        RoleCuisineVo roleCuisineVo = new RoleCuisineVo();

        roleCuisineVo.setCuisineId( arg0.getCuisineId() );
        roleCuisineVo.setDescription( arg0.getDescription() );
        roleCuisineVo.setId( arg0.getId() );
        roleCuisineVo.setRoleId( arg0.getRoleId() );
        roleCuisineVo.setType( arg0.getType() );

        return roleCuisineVo;
    }

    @Override
    public RoleCuisineVo convert(RoleCuisine arg0, RoleCuisineVo arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setCuisineId( arg0.getCuisineId() );
        arg1.setDescription( arg0.getDescription() );
        arg1.setId( arg0.getId() );
        arg1.setRoleId( arg0.getRoleId() );
        arg1.setType( arg0.getType() );

        return arg1;
    }
}
