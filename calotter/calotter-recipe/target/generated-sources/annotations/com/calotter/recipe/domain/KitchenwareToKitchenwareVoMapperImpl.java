package com.calotter.recipe.domain;

import com.calotter.recipe.domain.vo.KitchenwareVo;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T13:57:47+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class KitchenwareToKitchenwareVoMapperImpl implements KitchenwareToKitchenwareVoMapper {

    @Override
    public KitchenwareVo convert(Kitchenware arg0) {
        if ( arg0 == null ) {
            return null;
        }

        KitchenwareVo kitchenwareVo = new KitchenwareVo();

        kitchenwareVo.setCategory( arg0.getCategory() );
        kitchenwareVo.setDefaultShown( arg0.getDefaultShown() );
        kitchenwareVo.setDescription( arg0.getDescription() );
        kitchenwareVo.setElectronic( arg0.getElectronic() );
        kitchenwareVo.setId( arg0.getId() );
        kitchenwareVo.setImageUrl( arg0.getImageUrl() );
        kitchenwareVo.setName( arg0.getName() );

        return kitchenwareVo;
    }

    @Override
    public KitchenwareVo convert(Kitchenware arg0, KitchenwareVo arg1) {
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
