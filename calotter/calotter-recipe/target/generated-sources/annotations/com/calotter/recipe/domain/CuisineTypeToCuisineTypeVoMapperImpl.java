package com.calotter.recipe.domain;

import com.calotter.recipe.domain.vo.CuisineTypeVo;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-10T15:10:15+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class CuisineTypeToCuisineTypeVoMapperImpl implements CuisineTypeToCuisineTypeVoMapper {

    @Override
    public CuisineTypeVo convert(CuisineType arg0) {
        if ( arg0 == null ) {
            return null;
        }

        CuisineTypeVo cuisineTypeVo = new CuisineTypeVo();

        cuisineTypeVo.setIconUrl( arg0.getIconUrl() );
        cuisineTypeVo.setId( arg0.getId() );
        cuisineTypeVo.setName( arg0.getName() );
        cuisineTypeVo.setSort( arg0.getSort() );

        return cuisineTypeVo;
    }

    @Override
    public CuisineTypeVo convert(CuisineType arg0, CuisineTypeVo arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setIconUrl( arg0.getIconUrl() );
        arg1.setId( arg0.getId() );
        arg1.setName( arg0.getName() );
        arg1.setSort( arg0.getSort() );

        return arg1;
    }
}
