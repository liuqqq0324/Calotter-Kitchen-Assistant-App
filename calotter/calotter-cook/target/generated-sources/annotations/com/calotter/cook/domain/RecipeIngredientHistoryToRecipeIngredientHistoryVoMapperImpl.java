package com.calotter.cook.domain;

import com.calotter.cook.domain.vo.RecipeIngredientHistoryVo;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T13:57:45+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class RecipeIngredientHistoryToRecipeIngredientHistoryVoMapperImpl implements RecipeIngredientHistoryToRecipeIngredientHistoryVoMapper {

    @Override
    public RecipeIngredientHistoryVo convert(RecipeIngredientHistory arg0) {
        if ( arg0 == null ) {
            return null;
        }

        RecipeIngredientHistoryVo recipeIngredientHistoryVo = new RecipeIngredientHistoryVo();

        recipeIngredientHistoryVo.setId( arg0.getId() );
        recipeIngredientHistoryVo.setIngredientId( arg0.getIngredientId() );
        recipeIngredientHistoryVo.setQuantityUsed( arg0.getQuantityUsed() );
        recipeIngredientHistoryVo.setRecipeId( arg0.getRecipeId() );
        recipeIngredientHistoryVo.setSubstitution( arg0.getSubstitution() );
        recipeIngredientHistoryVo.setUnit( arg0.getUnit() );

        return recipeIngredientHistoryVo;
    }

    @Override
    public RecipeIngredientHistoryVo convert(RecipeIngredientHistory arg0, RecipeIngredientHistoryVo arg1) {
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
