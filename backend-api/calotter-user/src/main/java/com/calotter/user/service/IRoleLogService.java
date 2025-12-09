package com.calotter.user.service;

import com.calotter.user.domain.vo.RoleLogVo;
import com.calotter.user.domain.bo.RoleLogBo;
import com.calotter.common.mybatis.core.page.TableDataInfo;
import com.calotter.common.mybatis.core.page.PageQuery;

import java.util.Collection;
import java.util.List;

/**
 * ums_role_log;Stores body metrics of user roles. service interface
 *
 * @author Ruoyu Ji
 */
public interface IRoleLogService {

    /**
     * Query ums_role_log;Stores body metrics of user roles.
     *
     * @param id primary key
     * @return ums_role_log;Stores body metrics of user roles.
     */
    RoleLogVo queryById(Long id);

    /**
     * Pagination query ums_role_log;Stores body metrics of user roles. list
     *
     * @param bo        query condition
     * @param pageQuery pagination parameters
     * @return ums_role_log;Stores body metrics of user roles. paged list
     */
    TableDataInfo<RoleLogVo> queryPageList(RoleLogBo bo, PageQuery pageQuery);

    /**
     * Query the list of eligible ums_role_log;Stores body metrics of user roles. items
     *
     * @param bo query condition
     * @return ums_role_log;Stores body metrics of user roles. list
     */
    List<RoleLogVo> queryList(RoleLogBo bo);

    /**
     * Add ums_role_log;Stores body metrics of user roles.
     *
     * @param bo ums_role_log;Stores body metrics of user roles.
     * @return if the add operation is successful
     */
    Boolean insertByBo(RoleLogBo bo);

    /**
     * Modify ums_role_log;Stores body metrics of user roles.
     *
     * @param bo ums_role_log;Stores body metrics of user roles.
     * @return if the modification is successful
     */
    Boolean updateByBo(RoleLogBo bo);

    /**
     * Verify and batch delete ums_role_log;Stores body metrics of user roles. information
     *
     * @param ids     primary keys to be deleted
     * @param isValid whether to conduct a validation of effectiveness
     * @return if the delete operation is successful
     */
    Boolean deleteWithValidByIds(Collection<Long> ids, Boolean isValid);
}
