package com.calotter.recipe.service;

import com.calotter.recipe.domain.vo.KitchenwareVo;
import com.calotter.recipe.domain.bo.KitchenwareBo;
import com.calotter.common.mybatis.core.page.TableDataInfo;
import com.calotter.common.mybatis.core.page.PageQuery;

import java.util.Collection;
import java.util.List;

/**
 * rms_kitchenware;Global kitchenware table service interface
 *
 * @author Ruoyu Ji
 */
public interface IKitchenwareService {

    /**
     * Query rms_kitchenware;Global kitchenware table
     *
     * @param id primary key
     * @return rms_kitchenware;Global kitchenware table
     */
    KitchenwareVo queryById(Long id);

    /**
     * Pagination query rms_kitchenware;Global kitchenware table list
     *
     * @param bo        query condition
     * @param pageQuery pagination parameters
     * @return rms_kitchenware;Global kitchenware table paged list
     */
    TableDataInfo<KitchenwareVo> queryPageList(KitchenwareBo bo, PageQuery pageQuery);

    /**
     * Query the list of eligible rms_kitchenware;Global kitchenware table items
     *
     * @param bo query condition
     * @return rms_kitchenware;Global kitchenware table list
     */
    List<KitchenwareVo> queryList(KitchenwareBo bo);

    /**
     * Add rms_kitchenware;Global kitchenware table
     *
     * @param bo rms_kitchenware;Global kitchenware table
     * @return if the add operation is successful
     */
    Boolean insertByBo(KitchenwareBo bo);

    /**
     * Modify rms_kitchenware;Global kitchenware table
     *
     * @param bo rms_kitchenware;Global kitchenware table
     * @return if the modification is successful
     */
    Boolean updateByBo(KitchenwareBo bo);

    /**
     * Verify and batch delete rms_kitchenware;Global kitchenware table information
     *
     * @param ids     primary keys to be deleted
     * @param isValid whether to conduct a validation of effectiveness
     * @return if the delete operation is successful
     */
    Boolean deleteWithValidByIds(Collection<Long> ids, Boolean isValid);
}
