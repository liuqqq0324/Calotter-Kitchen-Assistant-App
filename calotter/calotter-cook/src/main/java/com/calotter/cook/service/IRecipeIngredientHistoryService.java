package com.calotter.cook.service;

import com.calotter.cook.domain.vo.RecipeIngredientHistoryVo;
import com.calotter.cook.domain.bo.RecipeIngredientHistoryBo;
import com.calotter.common.mybatis.core.page.TableDataInfo;
import com.calotter.common.mybatis.core.page.PageQuery;

import java.util.Collection;
import java.util.List;

/**
 * cms_recipe_ingredient_history;This table stores all associated data regarding which ingredients were consumed for a specific dish prepared by the user. service interface
 *
 * @author Ruoyu Ji
 */
public interface IRecipeIngredientHistoryService {

    /**
     * Query cms_recipe_ingredient_history;This table stores all associated data regarding which ingredients were consumed for a specific dish prepared by the user.
     *
     * @param id primary key
     * @return cms_recipe_ingredient_history;This table stores all associated data regarding which ingredients were consumed for a specific dish prepared by the user.
     */
    RecipeIngredientHistoryVo queryById(Long id);

    /**
     * Pagination query cms_recipe_ingredient_history;This table stores all associated data regarding which ingredients were consumed for a specific dish prepared by the user. list
     *
     * @param bo        query condition
     * @param pageQuery pagination parameters
     * @return cms_recipe_ingredient_history;This table stores all associated data regarding which ingredients were consumed for a specific dish prepared by the user. paged list
     */
    TableDataInfo<RecipeIngredientHistoryVo> queryPageList(RecipeIngredientHistoryBo bo, PageQuery pageQuery);

    /**
     * Query the list of eligible cms_recipe_ingredient_history;This table stores all associated data regarding which ingredients were consumed for a specific dish prepared by the user. items
     *
     * @param bo query condition
     * @return cms_recipe_ingredient_history;This table stores all associated data regarding which ingredients were consumed for a specific dish prepared by the user. list
     */
    List<RecipeIngredientHistoryVo> queryList(RecipeIngredientHistoryBo bo);

    /**
     * Add cms_recipe_ingredient_history;This table stores all associated data regarding which ingredients were consumed for a specific dish prepared by the user.
     *
     * @param bo cms_recipe_ingredient_history;This table stores all associated data regarding which ingredients were consumed for a specific dish prepared by the user.
     * @return if the add operation is successful
     */
    Boolean insertByBo(RecipeIngredientHistoryBo bo);

    /**
     * Modify cms_recipe_ingredient_history;This table stores all associated data regarding which ingredients were consumed for a specific dish prepared by the user.
     *
     * @param bo cms_recipe_ingredient_history;This table stores all associated data regarding which ingredients were consumed for a specific dish prepared by the user.
     * @return if the modification is successful
     */
    Boolean updateByBo(RecipeIngredientHistoryBo bo);

    /**
     * Verify and batch delete cms_recipe_ingredient_history;This table stores all associated data regarding which ingredients were consumed for a specific dish prepared by the user. information
     *
     * @param ids     primary keys to be deleted
     * @param isValid whether to conduct a validation of effectiveness
     * @return if the delete operation is successful
     */
    Boolean deleteWithValidByIds(Collection<Long> ids, Boolean isValid);
}
