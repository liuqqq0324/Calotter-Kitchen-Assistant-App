package com.calotter.recipe.domain.bo;

import com.calotter.recipe.domain.RecipeKitchenware;
import java.util.LinkedHashMap;
import java.util.Map;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-10T15:10:15+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class RecipeKitchenwareBoToRecipeKitchenwareMapperImpl implements RecipeKitchenwareBoToRecipeKitchenwareMapper {

    @Override
    public RecipeKitchenware convert(RecipeKitchenwareBo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        RecipeKitchenware recipeKitchenware = new RecipeKitchenware();

        recipeKitchenware.setCreateBy( arg0.getCreateBy() );
        recipeKitchenware.setCreateDept( arg0.getCreateDept() );
        recipeKitchenware.setCreateTime( arg0.getCreateTime() );
        Map<String, Object> map = arg0.getParams();
        if ( map != null ) {
            recipeKitchenware.setParams( new LinkedHashMap<String, Object>( map ) );
        }
        recipeKitchenware.setSearchValue( arg0.getSearchValue() );
        recipeKitchenware.setUpdateBy( arg0.getUpdateBy() );
        recipeKitchenware.setUpdateTime( arg0.getUpdateTime() );
        recipeKitchenware.setId( arg0.getId() );
        recipeKitchenware.setKitchenwareId( arg0.getKitchenwareId() );
        recipeKitchenware.setNote( arg0.getNote() );
        recipeKitchenware.setRecipeId( arg0.getRecipeId() );

        return recipeKitchenware;
    }

    @Override
    public RecipeKitchenware convert(RecipeKitchenwareBo arg0, RecipeKitchenware arg1) {
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
        arg1.setKitchenwareId( arg0.getKitchenwareId() );
        arg1.setNote( arg0.getNote() );
        arg1.setRecipeId( arg0.getRecipeId() );

        return arg1;
    }
}
