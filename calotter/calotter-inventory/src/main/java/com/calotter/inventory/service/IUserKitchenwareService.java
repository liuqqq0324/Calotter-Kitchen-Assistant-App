package com.calotter.inventory.service;

import com.calotter.inventory.domain.vo.UserKitchenwareVo;
import com.calotter.inventory.domain.bo.UserKitchenwareBo;
import com.calotter.common.mybatis.core.page.TableDataInfo;
import com.calotter.common.mybatis.core.page.PageQuery;

import java.util.Collection;
import java.util.List;

/**
 * ims_user_kitchenware;This table stores all user kitchenware, with each record containing the basic information of the kitchenware and the user to whom it belongs. service interface
 *
 * @author Ruoyu Ji
 */
public interface IUserKitchenwareService {

    /**
     * Query ims_user_kitchenware;This table stores all user kitchenware, with each record containing the basic information of the kitchenware and the user to whom it belongs.
     *
     * @param id primary key
     * @return ims_user_kitchenware;This table stores all user kitchenware, with each record containing the basic information of the kitchenware and the user to whom it belongs.
     */
    UserKitchenwareVo queryById(Long id);

    /**
     * Pagination query ims_user_kitchenware;This table stores all user kitchenware, with each record containing the basic information of the kitchenware and the user to whom it belongs. list
     *
     * @param bo        query condition
     * @param pageQuery pagination parameters
     * @return ims_user_kitchenware;This table stores all user kitchenware, with each record containing the basic information of the kitchenware and the user to whom it belongs. paged list
     */
    TableDataInfo<UserKitchenwareVo> queryPageList(UserKitchenwareBo bo, PageQuery pageQuery);

    /**
     * Query the list of eligible ims_user_kitchenware;This table stores all user kitchenware, with each record containing the basic information of the kitchenware and the user to whom it belongs. items
     *
     * @param bo query condition
     * @return ims_user_kitchenware;This table stores all user kitchenware, with each record containing the basic information of the kitchenware and the user to whom it belongs. list
     */
    List<UserKitchenwareVo> queryList(UserKitchenwareBo bo);

    /**
     * Add ims_user_kitchenware;This table stores all user kitchenware, with each record containing the basic information of the kitchenware and the user to whom it belongs.
     *
     * @param bo ims_user_kitchenware;This table stores all user kitchenware, with each record containing the basic information of the kitchenware and the user to whom it belongs.
     * @return if the add operation is successful
     */
    Boolean insertByBo(UserKitchenwareBo bo);

    /**
     * Modify ims_user_kitchenware;This table stores all user kitchenware, with each record containing the basic information of the kitchenware and the user to whom it belongs.
     *
     * @param bo ims_user_kitchenware;This table stores all user kitchenware, with each record containing the basic information of the kitchenware and the user to whom it belongs.
     * @return if the modification is successful
     */
    Boolean updateByBo(UserKitchenwareBo bo);

    /**
     * Verify and batch delete ims_user_kitchenware;This table stores all user kitchenware, with each record containing the basic information of the kitchenware and the user to whom it belongs. information
     *
     * @param ids     primary keys to be deleted
     * @param isValid whether to conduct a validation of effectiveness
     * @return if the delete operation is successful
     */
    Boolean deleteWithValidByIds(Collection<Long> ids, Boolean isValid);
}
