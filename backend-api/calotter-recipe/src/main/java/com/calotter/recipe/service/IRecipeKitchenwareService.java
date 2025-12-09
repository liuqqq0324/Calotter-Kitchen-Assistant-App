package com.calotter.recipe.service;

import com.calotter.recipe.domain.vo.RecipeKitchenwareVo;
import com.calotter.recipe.domain.bo.RecipeKitchenwareBo;
import com.calotter.common.mybatis.core.page.TableDataInfo;
import com.calotter.common.mybatis.core.page.PageQuery;

import java.util.Collection;
import java.util.List;

/**
 * rms_recipe_kitchenware;A light-weight association table which defines kitchenware requirements of recipes. service interface
 *
 * @author Ruoyu Ji
 */
public interface IRecipeKitchenwareService {

    /**
     * Query rms_recipe_kitchenware;A light-weight association table which defines kitchenware requirements of recipes.
     *
     * @param id primary key
     * @return rms_recipe_kitchenware;A light-weight association table which defines kitchenware requirements of recipes.
     */
    RecipeKitchenwareVo queryById(Long id);

    /**
     * Pagination query rms_recipe_kitchenware;A light-weight association table which defines kitchenware requirements of recipes. list
     *
     * @param bo        query condition
     * @param pageQuery pagination parameters
     * @return rms_recipe_kitchenware;A light-weight association table which defines kitchenware requirements of recipes. paged list
     */
    TableDataInfo<RecipeKitchenwareVo> queryPageList(RecipeKitchenwareBo bo, PageQuery pageQuery);

    /**
     * Query the list of eligible rms_recipe_kitchenware;A light-weight association table which defines kitchenware requirements of recipes. items
     *
     * @param bo query condition
     * @return rms_recipe_kitchenware;A light-weight association table which defines kitchenware requirements of recipes. list
     */
    List<RecipeKitchenwareVo> queryList(RecipeKitchenwareBo bo);

    /**
     * Add rms_recipe_kitchenware;A light-weight association table which defines kitchenware requirements of recipes.
     *
     * @param bo rms_recipe_kitchenware;A light-weight association table which defines kitchenware requirements of recipes.
     * @return if the add operation is successful
     */
    Boolean insertByBo(RecipeKitchenwareBo bo);

    /**
     * Modify rms_recipe_kitchenware;A light-weight association table which defines kitchenware requirements of recipes.
     *
     * @param bo rms_recipe_kitchenware;A light-weight association table which defines kitchenware requirements of recipes.
     * @return if the modification is successful
     */
    Boolean updateByBo(RecipeKitchenwareBo bo);

    /**
     * Verify and batch delete rms_recipe_kitchenware;A light-weight association table which defines kitchenware requirements of recipes. information
     *
     * @param ids     primary keys to be deleted
     * @param isValid whether to conduct a validation of effectiveness
     * @return if the delete operation is successful
     */
    Boolean deleteWithValidByIds(Collection<Long> ids, Boolean isValid);
}
