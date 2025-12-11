package com.calotter.recipe.service;

import com.calotter.recipe.domain.vo.CuisineTypeVo;
import com.calotter.recipe.domain.bo.CuisineTypeBo;
import com.calotter.common.mybatis.core.page.TableDataInfo;
import com.calotter.common.mybatis.core.page.PageQuery;

import java.util.Collection;
import java.util.List;

/**
 * rms_cuisine_type;The cuisine types of recipes service interface
 *
 * @author Ruoyu Ji
 */
public interface ICuisineTypeService {

    /**
     * Query rms_cuisine_type;The cuisine types of recipes
     *
     * @param id primary key
     * @return rms_cuisine_type;The cuisine types of recipes
     */
    CuisineTypeVo queryById(Long id);

    /**
     * Pagination query rms_cuisine_type;The cuisine types of recipes list
     *
     * @param bo        query condition
     * @param pageQuery pagination parameters
     * @return rms_cuisine_type;The cuisine types of recipes paged list
     */
    TableDataInfo<CuisineTypeVo> queryPageList(CuisineTypeBo bo, PageQuery pageQuery);

    /**
     * Query the list of eligible rms_cuisine_type;The cuisine types of recipes items
     *
     * @param bo query condition
     * @return rms_cuisine_type;The cuisine types of recipes list
     */
    List<CuisineTypeVo> queryList(CuisineTypeBo bo);

    /**
     * Add rms_cuisine_type;The cuisine types of recipes
     *
     * @param bo rms_cuisine_type;The cuisine types of recipes
     * @return if the add operation is successful
     */
    Boolean insertByBo(CuisineTypeBo bo);

    /**
     * Modify rms_cuisine_type;The cuisine types of recipes
     *
     * @param bo rms_cuisine_type;The cuisine types of recipes
     * @return if the modification is successful
     */
    Boolean updateByBo(CuisineTypeBo bo);

    /**
     * Verify and batch delete rms_cuisine_type;The cuisine types of recipes information
     *
     * @param ids     primary keys to be deleted
     * @param isValid whether to conduct a validation of effectiveness
     * @return if the delete operation is successful
     */
    Boolean deleteWithValidByIds(Collection<Long> ids, Boolean isValid);
}
