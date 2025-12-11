package com.calotter.recipe.domain;

import com.calotter.recipe.domain.vo.RecipeVo;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T13:57:47+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class RecipeToRecipeVoMapperImpl implements RecipeToRecipeVoMapper {

    @Override
    public RecipeVo convert(Recipe arg0) {
        if ( arg0 == null ) {
            return null;
        }

        RecipeVo recipeVo = new RecipeVo();

        recipeVo.setCaloriesPerServing( arg0.getCaloriesPerServing() );
        recipeVo.setCookTimeMinutes( arg0.getCookTimeMinutes() );
        recipeVo.setCuisineType( arg0.getCuisineType() );
        recipeVo.setDescription( arg0.getDescription() );
        recipeVo.setDifficultyLevel( arg0.getDifficultyLevel() );
        recipeVo.setId( arg0.getId() );
        recipeVo.setImageUrl( arg0.getImageUrl() );
        recipeVo.setInstructions( arg0.getInstructions() );
        recipeVo.setName( arg0.getName() );
        recipeVo.setPrepTimeMinutes( arg0.getPrepTimeMinutes() );
        recipeVo.setServingSize( arg0.getServingSize() );
        recipeVo.setTags( arg0.getTags() );
        recipeVo.setTotalTimeMinutes( arg0.getTotalTimeMinutes() );

        return recipeVo;
    }

    @Override
    public RecipeVo convert(Recipe arg0, RecipeVo arg1) {
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
