package com.calotter.recipe.domain;

import com.calotter.recipe.domain.vo.IngredientVo;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T14:29:59+1300",
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

        ingredientVo.setId( arg0.getId() );
        ingredientVo.setName( arg0.getName() );
        ingredientVo.setCategory( arg0.getCategory() );
        ingredientVo.setStandardUnit( arg0.getStandardUnit() );
        ingredientVo.setNutritionInfo( arg0.getNutritionInfo() );
        ingredientVo.setStorageAdvice( arg0.getStorageAdvice() );
        ingredientVo.setImageUrl( arg0.getImageUrl() );

        return ingredientVo;
    }

    @Override
    public IngredientVo convert(Ingredient arg0, IngredientVo arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setId( arg0.getId() );
        arg1.setName( arg0.getName() );
        arg1.setCategory( arg0.getCategory() );
        arg1.setStandardUnit( arg0.getStandardUnit() );
        arg1.setNutritionInfo( arg0.getNutritionInfo() );
        arg1.setStorageAdvice( arg0.getStorageAdvice() );
        arg1.setImageUrl( arg0.getImageUrl() );

        return arg1;
    }
}
