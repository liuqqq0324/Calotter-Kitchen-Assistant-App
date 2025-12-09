package com.calotter.inventory.service;

import com.calotter.inventory.domain.vo.UserIngredientVo;
import com.calotter.inventory.domain.bo.UserIngredientBo;
import com.calotter.common.mybatis.core.page.TableDataInfo;
import com.calotter.common.mybatis.core.page.PageQuery;

import java.util.Collection;
import java.util.List;

/**
 * ims_user_ingredient;This table stores all user ingredients. Each record contains the ingredient basic information and specifies which user owns it. service interface
 *
 * @author Ruoyu Ji
 */
public interface IUserIngredientService {

    /**
     * Query ims_user_ingredient;This table stores all user ingredients. Each record contains the ingredient basic information and specifies which user owns it.
     *
     * @param id primary key
     * @return ims_user_ingredient;This table stores all user ingredients. Each record contains the ingredient basic information and specifies which user owns it.
     */
    UserIngredientVo queryById(Long id);

    /**
     * Pagination query ims_user_ingredient;This table stores all user ingredients. Each record contains the ingredient basic information and specifies which user owns it. list
     *
     * @param bo        query condition
     * @param pageQuery pagination parameters
     * @return ims_user_ingredient;This table stores all user ingredients. Each record contains the ingredient basic information and specifies which user owns it. paged list
     */
    TableDataInfo<UserIngredientVo> queryPageList(UserIngredientBo bo, PageQuery pageQuery);

    /**
     * Query the list of eligible ims_user_ingredient;This table stores all user ingredients. Each record contains the ingredient basic information and specifies which user owns it. items
     *
     * @param bo query condition
     * @return ims_user_ingredient;This table stores all user ingredients. Each record contains the ingredient basic information and specifies which user owns it. list
     */
    List<UserIngredientVo> queryList(UserIngredientBo bo);

    /**
     * Add ims_user_ingredient;This table stores all user ingredients. Each record contains the ingredient basic information and specifies which user owns it.
     *
     * @param bo ims_user_ingredient;This table stores all user ingredients. Each record contains the ingredient basic information and specifies which user owns it.
     * @return if the add operation is successful
     */
    Boolean insertByBo(UserIngredientBo bo);

    /**
     * Modify ims_user_ingredient;This table stores all user ingredients. Each record contains the ingredient basic information and specifies which user owns it.
     *
     * @param bo ims_user_ingredient;This table stores all user ingredients. Each record contains the ingredient basic information and specifies which user owns it.
     * @return if the modification is successful
     */
    Boolean updateByBo(UserIngredientBo bo);

    /**
     * Verify and batch delete ims_user_ingredient;This table stores all user ingredients. Each record contains the ingredient basic information and specifies which user owns it. information
     *
     * @param ids     primary keys to be deleted
     * @param isValid whether to conduct a validation of effectiveness
     * @return if the delete operation is successful
     */
    Boolean deleteWithValidByIds(Collection<Long> ids, Boolean isValid);
}
