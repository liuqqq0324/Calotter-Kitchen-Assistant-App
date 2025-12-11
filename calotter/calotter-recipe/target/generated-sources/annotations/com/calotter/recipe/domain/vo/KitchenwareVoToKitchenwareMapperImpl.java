package com.calotter.recipe.domain.vo;

import com.calotter.recipe.domain.Kitchenware;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T17:42:09+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class KitchenwareVoToKitchenwareMapperImpl implements KitchenwareVoToKitchenwareMapper {

    @Override
    public Kitchenware convert(KitchenwareVo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        Kitchenware kitchenware = new Kitchenware();

        kitchenware.setCategory( arg0.getCategory() );
        kitchenware.setDefaultShown( arg0.getDefaultShown() );
        kitchenware.setDescription( arg0.getDescription() );
        kitchenware.setElectronic( arg0.getElectronic() );
        kitchenware.setId( arg0.getId() );
        kitchenware.setImageUrl( arg0.getImageUrl() );
        kitchenware.setName( arg0.getName() );

        return kitchenware;
    }

    @Override
    public Kitchenware convert(KitchenwareVo arg0, Kitchenware arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setCategory( arg0.getCategory() );
        arg1.setDefaultShown( arg0.getDefaultShown() );
        arg1.setDescription( arg0.getDescription() );
        arg1.setElectronic( arg0.getElectronic() );
        arg1.setId( arg0.getId() );
        arg1.setImageUrl( arg0.getImageUrl() );
        arg1.setName( arg0.getName() );

        return arg1;
    }
}
