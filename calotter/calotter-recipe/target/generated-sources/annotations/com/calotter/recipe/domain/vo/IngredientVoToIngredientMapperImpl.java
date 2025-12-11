package com.calotter.recipe.domain.vo;

import com.calotter.recipe.domain.Ingredient;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T13:57:47+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class IngredientVoToIngredientMapperImpl implements IngredientVoToIngredientMapper {

    @Override
    public Ingredient convert(IngredientVo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        Ingredient ingredient = new Ingredient();

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
    public Ingredient convert(IngredientVo arg0, Ingredient arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

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
