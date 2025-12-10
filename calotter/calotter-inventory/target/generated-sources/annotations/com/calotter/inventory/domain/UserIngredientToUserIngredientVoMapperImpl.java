package com.calotter.inventory.domain;

import com.calotter.inventory.domain.vo.UserIngredientVo;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-10T15:10:13+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class UserIngredientToUserIngredientVoMapperImpl implements UserIngredientToUserIngredientVoMapper {

    @Override
    public UserIngredientVo convert(UserIngredient arg0) {
        if ( arg0 == null ) {
            return null;
        }

        UserIngredientVo userIngredientVo = new UserIngredientVo();

        userIngredientVo.setCategoryType( arg0.getCategoryType() );
        userIngredientVo.setCurrentUnit( arg0.getCurrentUnit() );
        userIngredientVo.setExpirationDate( arg0.getExpirationDate() );
        userIngredientVo.setId( arg0.getId() );
        userIngredientVo.setIngredientId( arg0.getIngredientId() );
        userIngredientVo.setQuantity( arg0.getQuantity() );
        userIngredientVo.setStorageLocation( arg0.getStorageLocation() );
        userIngredientVo.setUserId( arg0.getUserId() );

        return userIngredientVo;
    }

    @Override
    public UserIngredientVo convert(UserIngredient arg0, UserIngredientVo arg1) {
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
