package com.calotter.recipe.service;

import com.calotter.recipe.domain.vo.IngredientVo;
import com.calotter.recipe.domain.bo.IngredientBo;
import com.calotter.common.mybatis.core.page.TableDataInfo;
import com.calotter.common.mybatis.core.page.PageQuery;

import java.util.Collection;
import java.util.List;

/**
 * rms_ingredient;Stores all ingredients could be used in a recipe. service interface
 *
 * @author Ruoyu Ji
 */
public interface IIngredientService {

    /**
     * Query rms_ingredient;Stores all ingredients could be used in a recipe.
     *
     * @param id primary key
     * @return rms_ingredient;Stores all ingredients could be used in a recipe.
     */
    IngredientVo queryById(Long id);

    /**
     * Pagination query rms_ingredient;Stores all ingredients could be used in a recipe. list
     *
     * @param bo        query condition
     * @param pageQuery pagination parameters
     * @return rms_ingredient;Stores all ingredients could be used in a recipe. paged list
     */
    TableDataInfo<IngredientVo> queryPageList(IngredientBo bo, PageQuery pageQuery);

    /**
     * Query the list of eligible rms_ingredient;Stores all ingredients could be used in a recipe. items
     *
     * @param bo query condition
     * @return rms_ingredient;Stores all ingredients could be used in a recipe. list
     */
    List<IngredientVo> queryList(IngredientBo bo);

    /**
     * Add rms_ingredient;Stores all ingredients could be used in a recipe.
     *
     * @param bo rms_ingredient;Stores all ingredients could be used in a recipe.
     * @return if the add operation is successful
     */
    Boolean insertByBo(IngredientBo bo);

    /**
     * Modify rms_ingredient;Stores all ingredients could be used in a recipe.
     *
     * @param bo rms_ingredient;Stores all ingredients could be used in a recipe.
     * @return if the modification is successful
     */
    Boolean updateByBo(IngredientBo bo);

    /**
     * Verify and batch delete rms_ingredient;Stores all ingredients could be used in a recipe. information
     *
     * @param ids     primary keys to be deleted
     * @param isValid whether to conduct a validation of effectiveness
     * @return if the delete operation is successful
     */
    Boolean deleteWithValidByIds(Collection<Long> ids, Boolean isValid);
}
