package com.calotter.user.service;

import com.calotter.user.domain.vo.RoleRestrictionVo;
import com.calotter.user.domain.bo.RoleRestrictionBo;
import com.calotter.common.mybatis.core.page.TableDataInfo;
import com.calotter.common.mybatis.core.page.PageQuery;

import java.util.Collection;
import java.util.List;

/**
 * ums_role_restriction;The dietary restrictions of specific dining role service interface
 *
 * @author Ruoyu Ji
 */
public interface IRoleRestrictionService {

    /**
     * Query ums_role_restriction;The dietary restrictions of specific dining role
     *
     * @param id primary key
     * @return ums_role_restriction;The dietary restrictions of specific dining role
     */
    RoleRestrictionVo queryById(Long id);

    /**
     * Pagination query ums_role_restriction;The dietary restrictions of specific dining role list
     *
     * @param bo        query condition
     * @param pageQuery pagination parameters
     * @return ums_role_restriction;The dietary restrictions of specific dining role paged list
     */
    TableDataInfo<RoleRestrictionVo> queryPageList(RoleRestrictionBo bo, PageQuery pageQuery);

    /**
     * Query the list of eligible ums_role_restriction;The dietary restrictions of specific dining role items
     *
     * @param bo query condition
     * @return ums_role_restriction;The dietary restrictions of specific dining role list
     */
    List<RoleRestrictionVo> queryList(RoleRestrictionBo bo);

    /**
     * Add ums_role_restriction;The dietary restrictions of specific dining role
     *
     * @param bo ums_role_restriction;The dietary restrictions of specific dining role
     * @return if the add operation is successful
     */
    Boolean insertByBo(RoleRestrictionBo bo);

    /**
     * Modify ums_role_restriction;The dietary restrictions of specific dining role
     *
     * @param bo ums_role_restriction;The dietary restrictions of specific dining role
     * @return if the modification is successful
     */
    Boolean updateByBo(RoleRestrictionBo bo);

    /**
     * Verify and batch delete ums_role_restriction;The dietary restrictions of specific dining role information
     *
     * @param ids     primary keys to be deleted
     * @param isValid whether to conduct a validation of effectiveness
     * @return if the delete operation is successful
     */
    Boolean deleteWithValidByIds(Collection<Long> ids, Boolean isValid);
}
