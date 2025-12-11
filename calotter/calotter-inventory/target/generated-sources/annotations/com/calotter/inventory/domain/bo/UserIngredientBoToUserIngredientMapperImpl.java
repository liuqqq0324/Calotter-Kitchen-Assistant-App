package com.calotter.inventory.domain.bo;

import com.calotter.inventory.domain.UserIngredient;
import java.util.LinkedHashMap;
import java.util.Map;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T14:29:57+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class UserIngredientBoToUserIngredientMapperImpl implements UserIngredientBoToUserIngredientMapper {

    @Override
    public UserIngredient convert(UserIngredientBo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        UserIngredient userIngredient = new UserIngredient();

        userIngredient.setCreateBy( arg0.getCreateBy() );
        userIngredient.setCreateDept( arg0.getCreateDept() );
        userIngredient.setCreateTime( arg0.getCreateTime() );
        Map<String, Object> map = arg0.getParams();
        if ( map != null ) {
            userIngredient.setParams( new LinkedHashMap<String, Object>( map ) );
        }
        userIngredient.setSearchValue( arg0.getSearchValue() );
        userIngredient.setUpdateBy( arg0.getUpdateBy() );
        userIngredient.setUpdateTime( arg0.getUpdateTime() );
        userIngredient.setId( arg0.getId() );
        userIngredient.setUserId( arg0.getUserId() );
        userIngredient.setIngredientId( arg0.getIngredientId() );
        userIngredient.setQuantity( arg0.getQuantity() );
        userIngredient.setCurrentUnit( arg0.getCurrentUnit() );
        userIngredient.setExpirationDate( arg0.getExpirationDate() );
        userIngredient.setStorageLocation( arg0.getStorageLocation() );
        userIngredient.setCategoryType( arg0.getCategoryType() );

        return userIngredient;
    }

    @Override
    public UserIngredient convert(UserIngredientBo arg0, UserIngredient arg1) {
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
        arg1.setUserId( arg0.getUserId() );
        arg1.setIngredientId( arg0.getIngredientId() );
        arg1.setQuantity( arg0.getQuantity() );
        arg1.setCurrentUnit( arg0.getCurrentUnit() );
        arg1.setExpirationDate( arg0.getExpirationDate() );
        arg1.setStorageLocation( arg0.getStorageLocation() );
        arg1.setCategoryType( arg0.getCategoryType() );

        return arg1;
    }
}
