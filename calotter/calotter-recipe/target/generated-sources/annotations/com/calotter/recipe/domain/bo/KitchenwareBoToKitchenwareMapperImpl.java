package com.calotter.recipe.domain.bo;

import com.calotter.recipe.domain.Kitchenware;
import java.util.LinkedHashMap;
import java.util.Map;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T14:29:59+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class KitchenwareBoToKitchenwareMapperImpl implements KitchenwareBoToKitchenwareMapper {

    @Override
    public Kitchenware convert(KitchenwareBo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        Kitchenware kitchenware = new Kitchenware();

        kitchenware.setCreateBy( arg0.getCreateBy() );
        kitchenware.setCreateDept( arg0.getCreateDept() );
        kitchenware.setCreateTime( arg0.getCreateTime() );
        Map<String, Object> map = arg0.getParams();
        if ( map != null ) {
            kitchenware.setParams( new LinkedHashMap<String, Object>( map ) );
        }
        kitchenware.setSearchValue( arg0.getSearchValue() );
        kitchenware.setUpdateBy( arg0.getUpdateBy() );
        kitchenware.setUpdateTime( arg0.getUpdateTime() );
        kitchenware.setId( arg0.getId() );
        kitchenware.setName( arg0.getName() );
        kitchenware.setDescription( arg0.getDescription() );
        kitchenware.setImageUrl( arg0.getImageUrl() );
        kitchenware.setCategory( arg0.getCategory() );
        kitchenware.setElectronic( arg0.getElectronic() );
        kitchenware.setDefaultShown( arg0.getDefaultShown() );

        return kitchenware;
    }

    @Override
    public Kitchenware convert(KitchenwareBo arg0, Kitchenware arg1) {
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
        arg1.setId( arg0.getId() );
        arg1.setName( arg0.getName() );
        arg1.setDescription( arg0.getDescription() );
        arg1.setImageUrl( arg0.getImageUrl() );
        arg1.setCategory( arg0.getCategory() );
        arg1.setElectronic( arg0.getElectronic() );
        arg1.setDefaultShown( arg0.getDefaultShown() );

        return arg1;
    }
}
