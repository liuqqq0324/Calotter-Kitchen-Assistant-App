package com.calotter.recipe.domain.vo;

import com.calotter.recipe.domain.Recipe;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T17:42:09+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class RecipeVoToRecipeMapperImpl implements RecipeVoToRecipeMapper {

    @Override
    public Recipe convert(RecipeVo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        Recipe recipe = new Recipe();

        recipe.setCaloriesPerServing( arg0.getCaloriesPerServing() );
        recipe.setCookTimeMinutes( arg0.getCookTimeMinutes() );
        recipe.setCuisineType( arg0.getCuisineType() );
        recipe.setDescription( arg0.getDescription() );
        recipe.setDifficultyLevel( arg0.getDifficultyLevel() );
        recipe.setId( arg0.getId() );
        recipe.setImageUrl( arg0.getImageUrl() );
        recipe.setInstructions( arg0.getInstructions() );
        recipe.setName( arg0.getName() );
        recipe.setPrepTimeMinutes( arg0.getPrepTimeMinutes() );
        recipe.setServingSize( arg0.getServingSize() );
        recipe.setTags( arg0.getTags() );
        recipe.setTotalTimeMinutes( arg0.getTotalTimeMinutes() );

        return recipe;
    }

    @Override
    public Recipe convert(RecipeVo arg0, Recipe arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setCaloriesPerServing( arg0.getCaloriesPerServing() );
        arg1.setCookTimeMinutes( arg0.getCookTimeMinutes() );
        arg1.setCuisineType( arg0.getCuisineType() );
        arg1.setDescription( arg0.getDescription() );
        arg1.setDifficultyLevel( arg0.getDifficultyLevel() );
        arg1.setId( arg0.getId() );
        arg1.setImageUrl( arg0.getImageUrl() );
        arg1.setInstructions( arg0.getInstructions() );
        arg1.setName( arg0.getName() );
        arg1.setPrepTimeMinutes( arg0.getPrepTimeMinutes() );
        arg1.setServingSize( arg0.getServingSize() );
        arg1.setTags( arg0.getTags() );
        arg1.setTotalTimeMinutes( arg0.getTotalTimeMinutes() );

        return arg1;
    }
}
