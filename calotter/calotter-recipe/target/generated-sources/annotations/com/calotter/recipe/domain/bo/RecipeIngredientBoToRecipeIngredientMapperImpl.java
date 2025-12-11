package com.calotter.recipe.domain.bo;

import com.calotter.recipe.domain.RecipeIngredient;
import java.util.LinkedHashMap;
import java.util.Map;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T17:42:09+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class RecipeIngredientBoToRecipeIngredientMapperImpl implements RecipeIngredientBoToRecipeIngredientMapper {

    @Override
    public RecipeIngredient convert(RecipeIngredientBo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        RecipeIngredient recipeIngredient = new RecipeIngredient();

        recipeIngredient.setCreateBy( arg0.getCreateBy() );
        recipeIngredient.setCreateDept( arg0.getCreateDept() );
        recipeIngredient.setCreateTime( arg0.getCreateTime() );
        Map<String, Object> map = arg0.getParams();
        if ( map != null ) {
            recipeIngredient.setParams( new LinkedHashMap<String, Object>( map ) );
        }
        recipeIngredient.setSearchValue( arg0.getSearchValue() );
        recipeIngredient.setUpdateBy( arg0.getUpdateBy() );
        recipeIngredient.setUpdateTime( arg0.getUpdateTime() );
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
    public RecipeIngredient convert(RecipeIngredientBo arg0, RecipeIngredient arg1) {
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
