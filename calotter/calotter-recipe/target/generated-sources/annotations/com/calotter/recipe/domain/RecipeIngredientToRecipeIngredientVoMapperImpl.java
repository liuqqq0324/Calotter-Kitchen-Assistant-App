package com.calotter.recipe.domain;

import com.calotter.recipe.domain.vo.RecipeIngredientVo;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T14:29:59+1300",
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

        recipeIngredientVo.setId( arg0.getId() );
        recipeIngredientVo.setRecipeId( arg0.getRecipeId() );
        recipeIngredientVo.setIngredientId( arg0.getIngredientId() );
        recipeIngredientVo.setQuantity( arg0.getQuantity() );
        recipeIngredientVo.setUnit( arg0.getUnit() );
        recipeIngredientVo.setProcessingNote( arg0.getProcessingNote() );
        recipeIngredientVo.setOptional( arg0.getOptional() );
        recipeIngredientVo.setGarnish( arg0.getGarnish() );
        recipeIngredientVo.setSort( arg0.getSort() );

        return recipeIngredientVo;
    }

    @Override
    public RecipeIngredientVo convert(RecipeIngredient arg0, RecipeIngredientVo arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setId( arg0.getId() );
        arg1.setRecipeId( arg0.getRecipeId() );
        arg1.setIngredientId( arg0.getIngredientId() );
        arg1.setQuantity( arg0.getQuantity() );
        arg1.setUnit( arg0.getUnit() );
        arg1.setProcessingNote( arg0.getProcessingNote() );
        arg1.setOptional( arg0.getOptional() );
        arg1.setGarnish( arg0.getGarnish() );
        arg1.setSort( arg0.getSort() );

        return arg1;
    }
}
