package com.calotter.recipe.domain.vo;

import com.calotter.recipe.domain.CuisineType;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T14:29:59+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class CuisineTypeVoToCuisineTypeMapperImpl implements CuisineTypeVoToCuisineTypeMapper {

    @Override
    public CuisineType convert(CuisineTypeVo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        CuisineType cuisineType = new CuisineType();

        cuisineType.setId( arg0.getId() );
        cuisineType.setName( arg0.getName() );
        cuisineType.setIconUrl( arg0.getIconUrl() );
        cuisineType.setSort( arg0.getSort() );

        return cuisineType;
    }

    @Override
    public CuisineType convert(CuisineTypeVo arg0, CuisineType arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setId( arg0.getId() );
        arg1.setName( arg0.getName() );
        arg1.setIconUrl( arg0.getIconUrl() );
        arg1.setSort( arg0.getSort() );

        return arg1;
    }
}
