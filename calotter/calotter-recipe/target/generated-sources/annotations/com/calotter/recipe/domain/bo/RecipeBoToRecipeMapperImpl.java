package com.calotter.recipe.domain.bo;

import com.calotter.recipe.domain.Recipe;
import java.util.LinkedHashMap;
import java.util.Map;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T14:29:59+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class RecipeBoToRecipeMapperImpl implements RecipeBoToRecipeMapper {

    @Override
    public Recipe convert(RecipeBo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        Recipe recipe = new Recipe();

        recipe.setSearchValue( arg0.getSearchValue() );
        recipe.setCreateDept( arg0.getCreateDept() );
        recipe.setCreateBy( arg0.getCreateBy() );
        recipe.setCreateTime( arg0.getCreateTime() );
        recipe.setUpdateBy( arg0.getUpdateBy() );
        recipe.setUpdateTime( arg0.getUpdateTime() );
        Map<String, Object> map = arg0.getParams();
        if ( map != null ) {
            recipe.setParams( new LinkedHashMap<String, Object>( map ) );
        }
        recipe.setId( arg0.getId() );
        recipe.setName( arg0.getName() );
        recipe.setDescription( arg0.getDescription() );
        recipe.setImageUrl( arg0.getImageUrl() );
        recipe.setCuisineType( arg0.getCuisineType() );
        recipe.setDifficultyLevel( arg0.getDifficultyLevel() );
        recipe.setServingSize( arg0.getServingSize() );
        recipe.setPrepTimeMinutes( arg0.getPrepTimeMinutes() );
        recipe.setCookTimeMinutes( arg0.getCookTimeMinutes() );
        recipe.setTotalTimeMinutes( arg0.getTotalTimeMinutes() );
        recipe.setCaloriesPerServing( arg0.getCaloriesPerServing() );
        recipe.setTags( arg0.getTags() );
        recipe.setInstructions( arg0.getInstructions() );

        return recipe;
    }

    @Override
    public Recipe convert(RecipeBo arg0, Recipe arg1) {
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
        arg1.setId( arg0.getId() );
        arg1.setName( arg0.getName() );
        arg1.setDescription( arg0.getDescription() );
        arg1.setImageUrl( arg0.getImageUrl() );
        arg1.setCuisineType( arg0.getCuisineType() );
        arg1.setDifficultyLevel( arg0.getDifficultyLevel() );
        arg1.setServingSize( arg0.getServingSize() );
        arg1.setPrepTimeMinutes( arg0.getPrepTimeMinutes() );
        arg1.setCookTimeMinutes( arg0.getCookTimeMinutes() );
        arg1.setTotalTimeMinutes( arg0.getTotalTimeMinutes() );
        arg1.setCaloriesPerServing( arg0.getCaloriesPerServing() );
        arg1.setTags( arg0.getTags() );
        arg1.setInstructions( arg0.getInstructions() );

        return arg1;
    }
}
