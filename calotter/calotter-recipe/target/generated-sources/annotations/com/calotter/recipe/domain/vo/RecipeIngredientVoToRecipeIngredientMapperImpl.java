package com.calotter.recipe.domain.vo;

import com.calotter.recipe.domain.RecipeIngredient;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-10T15:10:16+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class RecipeIngredientVoToRecipeIngredientMapperImpl implements RecipeIngredientVoToRecipeIngredientMapper {

    @Override
    public RecipeIngredient convert(RecipeIngredientVo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        RecipeIngredient recipeIngredient = new RecipeIngredient();

        recipeIngredient.setGarnish( arg0.getGarnish() );
        recipeIngredient.setId( arg0.getId() );
        recipeIngredient.setIngredientId( arg0.getIngredientId() );
        recipeIngredient.setOptional( arg0.getOptional() );
        recipeIngredient.setProcessingNote( arg0.getProcessingNote() );
        recipeIngredient.setQuantity( arg0.getQuantity() );
        recipeIngredient.setRecipeId( arg0.getRecipeId() );
        recipeIngredient.setSort( arg0.getSort() );
        recipeIngredient.setUnit( arg0.getUnit() );

        return recipeIngredient;
    }

    @Override
    public RecipeIngredient convert(RecipeIngredientVo arg0, RecipeIngredient arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setGarnish( arg0.getGarnish() );
        arg1.setId( arg0.getId() );
        arg1.setIngredientId( arg0.getIngredientId() );
        arg1.setOptional( arg0.getOptional() );
        arg1.setProcessingNote( arg0.getProcessingNote() );
        arg1.setQuantity( arg0.getQuantity() );
        arg1.setRecipeId( arg0.getRecipeId() );
        arg1.setSort( arg0.getSort() );
        arg1.setUnit( arg0.getUnit() );

        return arg1;
    }
}
