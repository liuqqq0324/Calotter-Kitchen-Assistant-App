package com.calotter.cook.domain.vo;

import com.calotter.cook.domain.RecipeIngredientHistory;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-10T15:10:11+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class RecipeIngredientHistoryVoToRecipeIngredientHistoryMapperImpl implements RecipeIngredientHistoryVoToRecipeIngredientHistoryMapper {

    @Override
    public RecipeIngredientHistory convert(RecipeIngredientHistoryVo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        RecipeIngredientHistory recipeIngredientHistory = new RecipeIngredientHistory();

        recipeIngredientHistory.setId( arg0.getId() );
        recipeIngredientHistory.setIngredientId( arg0.getIngredientId() );
        recipeIngredientHistory.setQuantityUsed( arg0.getQuantityUsed() );
        recipeIngredientHistory.setRecipeId( arg0.getRecipeId() );
        recipeIngredientHistory.setSubstitution( arg0.getSubstitution() );
        recipeIngredientHistory.setUnit( arg0.getUnit() );

        return recipeIngredientHistory;
    }

    @Override
    public RecipeIngredientHistory convert(RecipeIngredientHistoryVo arg0, RecipeIngredientHistory arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setId( arg0.getId() );
        arg1.setIngredientId( arg0.getIngredientId() );
        arg1.setQuantityUsed( arg0.getQuantityUsed() );
        arg1.setRecipeId( arg0.getRecipeId() );
        arg1.setSubstitution( arg0.getSubstitution() );
        arg1.setUnit( arg0.getUnit() );

        return arg1;
    }
}
