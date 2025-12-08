package com.calotter.user.service;

import com.calotter.user.domain.vo.RolePreferenceVo;
import com.calotter.user.domain.bo.RolePreferenceBo;
import com.calotter.common.mybatis.core.page.TableDataInfo;
import com.calotter.common.mybatis.core.page.PageQuery;

import java.util.Collection;
import java.util.List;

/**
 * ums_role_preference;The dietary preference of specific dining role service interface
 *
 * @author Ruoyu Ji
 */
public interface IRolePreferenceService {

    /**
     * Query ums_role_preference;The dietary preference of specific dining role
     *
     * @param id primary key
     * @return ums_role_preference;The dietary preference of specific dining role
     */
    RolePreferenceVo queryById(Long id);

    /**
     * Pagination query ums_role_preference;The dietary preference of specific dining role list
     *
     * @param bo        query condition
     * @param pageQuery pagination parameters
     * @return ums_role_preference;The dietary preference of specific dining role paged list
     */
    TableDataInfo<RolePreferenceVo> queryPageList(RolePreferenceBo bo, PageQuery pageQuery);

    /**
     * Query the list of eligible ums_role_preference;The dietary preference of specific dining role items
     *
     * @param bo query condition
     * @return ums_role_preference;The dietary preference of specific dining role list
     */
    List<RolePreferenceVo> queryList(RolePreferenceBo bo);

    /**
     * Add ums_role_preference;The dietary preference of specific dining role
     *
     * @param bo ums_role_preference;The dietary preference of specific dining role
     * @return if the add operation is successful
     */
    Boolean insertByBo(RolePreferenceBo bo);

    /**
     * Modify ums_role_preference;The dietary preference of specific dining role
     *
     * @param bo ums_role_preference;The dietary preference of specific dining role
     * @return if the modification is successful
     */
    Boolean updateByBo(RolePreferenceBo bo);

    /**
     * Verify and batch delete ums_role_preference;The dietary preference of specific dining role information
     *
     * @param ids     primary keys to be deleted
     * @param isValid whether to conduct a validation of effectiveness
     * @return if the delete operation is successful
     */
    Boolean deleteWithValidByIds(Collection<Long> ids, Boolean isValid);
}
