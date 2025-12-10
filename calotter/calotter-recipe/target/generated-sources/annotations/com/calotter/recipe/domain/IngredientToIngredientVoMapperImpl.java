package com.calotter.recipe.domain;

import com.calotter.recipe.domain.vo.IngredientVo;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-10T15:10:15+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class IngredientToIngredientVoMapperImpl implements IngredientToIngredientVoMapper {

    @Override
    public IngredientVo convert(Ingredient arg0) {
        if ( arg0 == null ) {
            return null;
        }

        IngredientVo ingredientVo = new IngredientVo();

        ingredientVo.setCategory( arg0.getCategory() );
        ingredientVo.setId( arg0.getId() );
        ingredientVo.setImageUrl( arg0.getImageUrl() );
        ingredientVo.setName( arg0.getName() );
        ingredientVo.setNutritionInfo( arg0.getNutritionInfo() );
        ingredientVo.setStandardUnit( arg0.getStandardUnit() );
        ingredientVo.setStorageAdvice( arg0.getStorageAdvice() );

        return ingredientVo;
    }

    @Override
    public IngredientVo convert(Ingredient arg0, IngredientVo arg1) {
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
