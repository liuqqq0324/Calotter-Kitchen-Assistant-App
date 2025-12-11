package com.calotter.recipe.domain.vo;

import com.calotter.recipe.domain.RecipeKitchenware;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T17:42:09+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class RecipeKitchenwareVoToRecipeKitchenwareMapperImpl implements RecipeKitchenwareVoToRecipeKitchenwareMapper {

    @Override
    public RecipeKitchenware convert(RecipeKitchenwareVo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        RecipeKitchenware recipeKitchenware = new RecipeKitchenware();

        recipeKitchenware.setId( arg0.getId() );
        recipeKitchenware.setKitchenwareId( arg0.getKitchenwareId() );
        recipeKitchenware.setNote( arg0.getNote() );
        recipeKitchenware.setRecipeId( arg0.getRecipeId() );

        return recipeKitchenware;
    }

    @Override
    public RecipeKitchenware convert(RecipeKitchenwareVo arg0, RecipeKitchenware arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setId( arg0.getId() );
        arg1.setKitchenwareId( arg0.getKitchenwareId() );
        arg1.setNote( arg0.getNote() );
        arg1.setRecipeId( arg0.getRecipeId() );

        return arg1;
    }
}
