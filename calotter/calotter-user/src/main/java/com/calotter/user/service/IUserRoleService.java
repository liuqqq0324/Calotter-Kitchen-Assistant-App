package com.calotter.user.service;

import com.calotter.user.domain.vo.UserRoleVo;
import com.calotter.user.domain.bo.UserRoleBo;
import com.calotter.common.mybatis.core.page.TableDataInfo;
import com.calotter.common.mybatis.core.page.PageQuery;

import java.util.Collection;
import java.util.List;

/**
 * ums_user_role;This table represents the user role. A user can cook for one to multiple diners (user role). Each record in this table stores all information about a role, along with the account to which that role belongs. service interface
 *
 * @author Ruoyu Ji
 */
public interface IUserRoleService {

    /**
     * Query ums_user_role;This table represents the user role. A user can cook for one to multiple diners (user role). Each record in this table stores all information about a role, along with the account to which that role belongs.
     *
     * @param id primary key
     * @return ums_user_role;This table represents the user role. A user can cook for one to multiple diners (user role). Each record in this table stores all information about a role, along with the account to which that role belongs.
     */
    UserRoleVo queryById(Long id);

    /**
     * Pagination query ums_user_role;This table represents the user role. A user can cook for one to multiple diners (user role). Each record in this table stores all information about a role, along with the account to which that role belongs. list
     *
     * @param bo        query condition
     * @param pageQuery pagination parameters
     * @return ums_user_role;This table represents the user role. A user can cook for one to multiple diners (user role). Each record in this table stores all information about a role, along with the account to which that role belongs. paged list
     */
    TableDataInfo<UserRoleVo> queryPageList(UserRoleBo bo, PageQuery pageQuery);

    /**
     * Query the list of eligible ums_user_role;This table represents the user role. A user can cook for one to multiple diners (user role). Each record in this table stores all information about a role, along with the account to which that role belongs. items
     *
     * @param bo query condition
     * @return ums_user_role;This table represents the user role. A user can cook for one to multiple diners (user role). Each record in this table stores all information about a role, along with the account to which that role belongs. list
     */
    List<UserRoleVo> queryList(UserRoleBo bo);

    /**
     * Add ums_user_role;This table represents the user role. A user can cook for one to multiple diners (user role). Each record in this table stores all information about a role, along with the account to which that role belongs.
     *
     * @param bo ums_user_role;This table represents the user role. A user can cook for one to multiple diners (user role). Each record in this table stores all information about a role, along with the account to which that role belongs.
     * @return if the add operation is successful
     */
    Boolean insertByBo(UserRoleBo bo);

    /**
     * Modify ums_user_role;This table represents the user role. A user can cook for one to multiple diners (user role). Each record in this table stores all information about a role, along with the account to which that role belongs.
     *
     * @param bo ums_user_role;This table represents the user role. A user can cook for one to multiple diners (user role). Each record in this table stores all information about a role, along with the account to which that role belongs.
     * @return if the modification is successful
     */
    Boolean updateByBo(UserRoleBo bo);

    /**
     * Verify and batch delete ums_user_role;This table represents the user role. A user can cook for one to multiple diners (user role). Each record in this table stores all information about a role, along with the account to which that role belongs. information
     *
     * @param ids     primary keys to be deleted
     * @param isValid whether to conduct a validation of effectiveness
     * @return if the delete operation is successful
     */
    Boolean deleteWithValidByIds(Collection<Long> ids, Boolean isValid);
}
