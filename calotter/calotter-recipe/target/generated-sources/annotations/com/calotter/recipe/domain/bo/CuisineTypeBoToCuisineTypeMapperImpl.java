package com.calotter.recipe.domain.bo;

import com.calotter.recipe.domain.CuisineType;
import java.util.LinkedHashMap;
import java.util.Map;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T17:42:09+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class CuisineTypeBoToCuisineTypeMapperImpl implements CuisineTypeBoToCuisineTypeMapper {

    @Override
    public CuisineType convert(CuisineTypeBo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        CuisineType cuisineType = new CuisineType();

        cuisineType.setCreateBy( arg0.getCreateBy() );
        cuisineType.setCreateDept( arg0.getCreateDept() );
        cuisineType.setCreateTime( arg0.getCreateTime() );
        Map<String, Object> map = arg0.getParams();
        if ( map != null ) {
            cuisineType.setParams( new LinkedHashMap<String, Object>( map ) );
        }
        cuisineType.setSearchValue( arg0.getSearchValue() );
        cuisineType.setUpdateBy( arg0.getUpdateBy() );
        cuisineType.setUpdateTime( arg0.getUpdateTime() );
        cuisineType.setIconUrl( arg0.getIconUrl() );
        cuisineType.setId( arg0.getId() );
        cuisineType.setName( arg0.getName() );
        cuisineType.setSort( arg0.getSort() );

        return cuisineType;
    }

    @Override
    public CuisineType convert(CuisineTypeBo arg0, CuisineType arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setCreateBy( arg0.getCreateBy() );
        arg1.setCreateDept( arg0.getCreateDept() );
        arg1.setCreateTime( arg0.getCreateTime() );
        if ( arg1.getParams() != null ) {
            Map<String, Object> map = arg0.getParams();
            if ( map != null ) {
                arg1.getParams().clear();
                arg1.getParams().putAll( map );
            }
            else {
                arg1.setParams( null );
            }
        }
        else {
            Map<String, Object> map = arg0.getParams();
            if ( map != null ) {
                arg1.setParams( new LinkedHashMap<String, Object>( map ) );
            }
        }
        arg1.setSearchValue( arg0.getSearchValue() );
        arg1.setUpdateBy( arg0.getUpdateBy() );
        arg1.setUpdateTime( arg0.getUpdateTime() );
        arg1.setIconUrl( arg0.getIconUrl() );
        arg1.setId( arg0.getId() );
        arg1.setName( arg0.getName() );
        arg1.setSort( arg0.getSort() );

        return arg1;
    }
}
