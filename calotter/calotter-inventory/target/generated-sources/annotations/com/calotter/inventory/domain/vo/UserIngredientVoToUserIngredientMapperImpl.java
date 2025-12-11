package com.calotter.inventory.domain.vo;

import com.calotter.inventory.domain.UserIngredient;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T13:57:46+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class UserIngredientVoToUserIngredientMapperImpl implements UserIngredientVoToUserIngredientMapper {

    @Override
    public UserIngredient convert(UserIngredientVo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        UserIngredient userIngredient = new UserIngredient();

        userIngredient.setCategoryType( arg0.getCategoryType() );
        userIngredient.setCurrentUnit( arg0.getCurrentUnit() );
        userIngredient.setExpirationDate( arg0.getExpirationDate() );
        userIngredient.setId( arg0.getId() );
        userIngredient.setIngredientId( arg0.getIngredientId() );
        userIngredient.setQuantity( arg0.getQuantity() );
        userIngredient.setStorageLocation( arg0.getStorageLocation() );
        userIngredient.setUserId( arg0.getUserId() );

        return userIngredient;
    }

    @Override
    public UserIngredient convert(UserIngredientVo arg0, UserIngredient arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setCategoryType( arg0.getCategoryType() );
        arg1.setCurrentUnit( arg0.getCurrentUnit() );
        arg1.setExpirationDate( arg0.getExpirationDate() );
        arg1.setId( arg0.getId() );
        arg1.setIngredientId( arg0.getIngredientId() );
        arg1.setQuantity( arg0.getQuantity() );
        arg1.setStorageLocation( arg0.getStorageLocation() );
        arg1.setUserId( arg0.getUserId() );

        return arg1;
    }
}
