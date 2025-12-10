package com.calotter.recipe.domain.bo;

import com.calotter.recipe.domain.Ingredient;
import java.util.LinkedHashMap;
import java.util.Map;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-10T15:10:15+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class IngredientBoToIngredientMapperImpl implements IngredientBoToIngredientMapper {

    @Override
    public Ingredient convert(IngredientBo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        Ingredient ingredient = new Ingredient();

        ingredient.setCreateBy( arg0.getCreateBy() );
        ingredient.setCreateDept( arg0.getCreateDept() );
        ingredient.setCreateTime( arg0.getCreateTime() );
        Map<String, Object> map = arg0.getParams();
        if ( map != null ) {
            ingredient.setParams( new LinkedHashMap<String, Object>( map ) );
        }
        ingredient.setSearchValue( arg0.getSearchValue() );
        ingredient.setUpdateBy( arg0.getUpdateBy() );
        ingredient.setUpdateTime( arg0.getUpdateTime() );
        ingredient.setCategory( arg0.getCategory() );
        ingredient.setId( arg0.getId() );
        ingredient.setImageUrl( arg0.getImageUrl() );
        ingredient.setName( arg0.getName() );
        ingredient.setNutritionInfo( arg0.getNutritionInfo() );
        ingredient.setStandardUnit( arg0.getStandardUnit() );
        ingredient.setStorageAdvice( arg0.getStorageAdvice() );

        return ingredient;
    }

    @Override
    public Ingredient convert(IngredientBo arg0, Ingredient arg1) {
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
        arg1.setCategory( arg0.getCategory() );
        arg1.setId( arg0.getId() );
        arg1.setImageUrl( arg0.getImageUrl() );
        arg1.setName( arg0.getName() );
        arg1.setNutritionInfo( arg0.getNutritionInfo() );
        arg1.setStandardUnit( arg0.getStandardUnit() );
        arg1.setStorageAdvice( arg0.getStorageAdvice() );

        return arg1;
    }
}
