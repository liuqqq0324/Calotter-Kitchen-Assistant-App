package com.calotter.user.service;

import com.calotter.user.domain.vo.UserVo;
import com.calotter.user.domain.bo.UserBo;
import com.calotter.common.mybatis.core.page.TableDataInfo;
import com.calotter.common.mybatis.core.page.PageQuery;

import java.util.Collection;
import java.util.List;

/**
 * ums_user;This table is the master user table, storing the basic information of all users. service interface
 *
 * @author Ruoyu Ji
 */
public interface IUserService {

    /**
     * Query ums_user;This table is the master user table, storing the basic information of all users.
     *
     * @param id primary key
     * @return ums_user;This table is the master user table, storing the basic information of all users.
     */
    UserVo queryById(Long id);

    /**
     * Pagination query ums_user;This table is the master user table, storing the basic information of all users. list
     *
     * @param bo        query condition
     * @param pageQuery pagination parameters
     * @return ums_user;This table is the master user table, storing the basic information of all users. paged list
     */
    TableDataInfo<UserVo> queryPageList(UserBo bo, PageQuery pageQuery);

    /**
     * Query the list of eligible ums_user;This table is the master user table, storing the basic information of all users. items
     *
     * @param bo query condition
     * @return ums_user;This table is the master user table, storing the basic information of all users. list
     */
    List<UserVo> queryList(UserBo bo);

    /**
     * Add ums_user;This table is the master user table, storing the basic information of all users.
     *
     * @param bo ums_user;This table is the master user table, storing the basic information of all users.
     * @return if the add operation is successful
     */
    Boolean insertByBo(UserBo bo);

    /**
     * Modify ums_user;This table is the master user table, storing the basic information of all users.
     *
     * @param bo ums_user;This table is the master user table, storing the basic information of all users.
     * @return if the modification is successful
     */
    Boolean updateByBo(UserBo bo);

    /**
     * Verify and batch delete ums_user;This table is the master user table, storing the basic information of all users. information
     *
     * @param ids     primary keys to be deleted
     * @param isValid whether to conduct a validation of effectiveness
     * @return if the delete operation is successful
     */
    Boolean deleteWithValidByIds(Collection<Long> ids, Boolean isValid);
}
