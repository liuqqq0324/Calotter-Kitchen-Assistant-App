package com.calotter.recipe.service;

import com.calotter.recipe.domain.vo.RecipeIngredientVo;
import com.calotter.recipe.domain.bo.RecipeIngredientBo;
import com.calotter.common.mybatis.core.page.TableDataInfo;
import com.calotter.common.mybatis.core.page.PageQuery;

import java.util.Collection;
import java.util.List;

/**
 * rms_recipe_ingredient;Store the ingredient compositions of recipes. service interface
 *
 * @author Ruoyu Ji
 */
public interface IRecipeIngredientService {

    /**
     * Query rms_recipe_ingredient;Store the ingredient compositions of recipes.
     *
     * @param id primary key
     * @return rms_recipe_ingredient;Store the ingredient compositions of recipes.
     */
    RecipeIngredientVo queryById(Long id);

    /**
     * Pagination query rms_recipe_ingredient;Store the ingredient compositions of recipes. list
     *
     * @param bo        query condition
     * @param pageQuery pagination parameters
     * @return rms_recipe_ingredient;Store the ingredient compositions of recipes. paged list
     */
    TableDataInfo<RecipeIngredientVo> queryPageList(RecipeIngredientBo bo, PageQuery pageQuery);

    /**
     * Query the list of eligible rms_recipe_ingredient;Store the ingredient compositions of recipes. items
     *
     * @param bo query condition
     * @return rms_recipe_ingredient;Store the ingredient compositions of recipes. list
     */
    List<RecipeIngredientVo> queryList(RecipeIngredientBo bo);

    /**
     * Add rms_recipe_ingredient;Store the ingredient compositions of recipes.
     *
     * @param bo rms_recipe_ingredient;Store the ingredient compositions of recipes.
     * @return if the add operation is successful
     */
    Boolean insertByBo(RecipeIngredientBo bo);

    /**
     * Modify rms_recipe_ingredient;Store the ingredient compositions of recipes.
     *
     * @param bo rms_recipe_ingredient;Store the ingredient compositions of recipes.
     * @return if the modification is successful
     */
    Boolean updateByBo(RecipeIngredientBo bo);

    /**
     * Verify and batch delete rms_recipe_ingredient;Store the ingredient compositions of recipes. information
     *
     * @param ids     primary keys to be deleted
     * @param isValid whether to conduct a validation of effectiveness
     * @return if the delete operation is successful
     */
    Boolean deleteWithValidByIds(Collection<Long> ids, Boolean isValid);
}
