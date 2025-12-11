package com.calotter.cook.domain.bo;

import com.calotter.cook.domain.RecipeIngredientHistory;
import java.util.LinkedHashMap;
import java.util.Map;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T14:29:53+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class RecipeIngredientHistoryBoToRecipeIngredientHistoryMapperImpl implements RecipeIngredientHistoryBoToRecipeIngredientHistoryMapper {

    @Override
    public RecipeIngredientHistory convert(RecipeIngredientHistoryBo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        RecipeIngredientHistory recipeIngredientHistory = new RecipeIngredientHistory();

        recipeIngredientHistory.setCreateBy( arg0.getCreateBy() );
        recipeIngredientHistory.setCreateDept( arg0.getCreateDept() );
        recipeIngredientHistory.setCreateTime( arg0.getCreateTime() );
        Map<String, Object> map = arg0.getParams();
        if ( map != null ) {
            recipeIngredientHistory.setParams( new LinkedHashMap<String, Object>( map ) );
        }
        recipeIngredientHistory.setSearchValue( arg0.getSearchValue() );
        recipeIngredientHistory.setUpdateBy( arg0.getUpdateBy() );
        recipeIngredientHistory.setUpdateTime( arg0.getUpdateTime() );
        recipeIngredientHistory.setId( arg0.getId() );
        recipeIngredientHistory.setRecipeId( arg0.getRecipeId() );
        recipeIngredientHistory.setIngredientId( arg0.getIngredientId() );
        recipeIngredientHistory.setQuantityUsed( arg0.getQuantityUsed() );
        recipeIngredientHistory.setUnit( arg0.getUnit() );
        recipeIngredientHistory.setSubstitution( arg0.getSubstitution() );

        return recipeIngredientHistory;
    }

    @Override
    public RecipeIngredientHistory convert(RecipeIngredientHistoryBo arg0, RecipeIngredientHistory arg1) {
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
        arg1.setRecipeId( arg0.getRecipeId() );
        arg1.setIngredientId( arg0.getIngredientId() );
        arg1.setQuantityUsed( arg0.getQuantityUsed() );
        arg1.setUnit( arg0.getUnit() );
        arg1.setSubstitution( arg0.getSubstitution() );

        return arg1;
    }
}
