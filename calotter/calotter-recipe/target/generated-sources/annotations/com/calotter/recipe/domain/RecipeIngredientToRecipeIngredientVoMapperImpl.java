package com.calotter.recipe.domain;

import com.calotter.recipe.domain.vo.RecipeIngredientVo;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T17:42:09+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class RecipeIngredientToRecipeIngredientVoMapperImpl implements RecipeIngredientToRecipeIngredientVoMapper {

    @Override
    public RecipeIngredientVo convert(RecipeIngredient arg0) {
        if ( arg0 == null ) {
            return null;
        }

        RecipeIngredientVo recipeIngredientVo = new RecipeIngredientVo();

        recipeIngredientVo.setGarnish( arg0.getGarnish() );
        recipeIngredientVo.setId( arg0.getId() );
        recipeIngredientVo.setIngredientId( arg0.getIngredientId() );
        recipeIngredientVo.setOptional( arg0.getOptional() );
        recipeIngredientVo.setProcessingNote( arg0.getProcessingNote() );
        recipeIngredientVo.setQuantity( arg0.getQuantity() );
        recipeIngredientVo.setRecipeId( arg0.getRecipeId() );
        recipeIngredientVo.setSort( arg0.getSort() );
        recipeIngredientVo.setUnit( arg0.getUnit() );

        return recipeIngredientVo;
    }

    @Override
    public RecipeIngredientVo convert(RecipeIngredient arg0, RecipeIngredientVo arg1) {
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
