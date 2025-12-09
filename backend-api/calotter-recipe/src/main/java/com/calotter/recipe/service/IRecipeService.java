package com.calotter.recipe.service;

import com.calotter.recipe.domain.vo.RecipeVo;
import com.calotter.recipe.domain.bo.RecipeBo;
import com.calotter.common.mybatis.core.page.TableDataInfo;
import com.calotter.common.mybatis.core.page.PageQuery;

import java.util.Collection;
import java.util.List;

/**
 * rms_recipe;Stores all recipes and the corresponding ingredients. service interface
 *
 * @author Ruoyu Ji
 */
public interface IRecipeService {

    /**
     * Query rms_recipe;Stores all recipes and the corresponding ingredients.
     *
     * @param id primary key
     * @return rms_recipe;Stores all recipes and the corresponding ingredients.
     */
    RecipeVo queryById(Long id);

    /**
     * Pagination query rms_recipe;Stores all recipes and the corresponding ingredients. list
     *
     * @param bo        query condition
     * @param pageQuery pagination parameters
     * @return rms_recipe;Stores all recipes and the corresponding ingredients. paged list
     */
    TableDataInfo<RecipeVo> queryPageList(RecipeBo bo, PageQuery pageQuery);

    /**
     * Query the list of eligible rms_recipe;Stores all recipes and the corresponding ingredients. items
     *
     * @param bo query condition
     * @return rms_recipe;Stores all recipes and the corresponding ingredients. list
     */
    List<RecipeVo> queryList(RecipeBo bo);

    /**
     * Add rms_recipe;Stores all recipes and the corresponding ingredients.
     *
     * @param bo rms_recipe;Stores all recipes and the corresponding ingredients.
     * @return if the add operation is successful
     */
    Boolean insertByBo(RecipeBo bo);

    /**
     * Modify rms_recipe;Stores all recipes and the corresponding ingredients.
     *
     * @param bo rms_recipe;Stores all recipes and the corresponding ingredients.
     * @return if the modification is successful
     */
    Boolean updateByBo(RecipeBo bo);

    /**
     * Verify and batch delete rms_recipe;Stores all recipes and the corresponding ingredients. information
     *
     * @param ids     primary keys to be deleted
     * @param isValid whether to conduct a validation of effectiveness
     * @return if the delete operation is successful
     */
    Boolean deleteWithValidByIds(Collection<Long> ids, Boolean isValid);
}
