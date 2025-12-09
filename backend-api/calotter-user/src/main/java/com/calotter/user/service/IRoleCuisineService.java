package com.calotter.user.service;

import com.calotter.user.domain.vo.RoleCuisineVo;
import com.calotter.user.domain.bo.RoleCuisineBo;
import com.calotter.common.mybatis.core.page.TableDataInfo;
import com.calotter.common.mybatis.core.page.PageQuery;

import java.util.Collection;
import java.util.List;

/**
 * ums_role_cuisine;The association table of dining role and cuisine service interface
 *
 * @author Ruoyu Ji
 */
public interface IRoleCuisineService {

    /**
     * Query ums_role_cuisine;The association table of dining role and cuisine
     *
     * @param id primary key
     * @return ums_role_cuisine;The association table of dining role and cuisine
     */
    RoleCuisineVo queryById(Long id);

    /**
     * Pagination query ums_role_cuisine;The association table of dining role and cuisine list
     *
     * @param bo        query condition
     * @param pageQuery pagination parameters
     * @return ums_role_cuisine;The association table of dining role and cuisine paged list
     */
    TableDataInfo<RoleCuisineVo> queryPageList(RoleCuisineBo bo, PageQuery pageQuery);

    /**
     * Query the list of eligible ums_role_cuisine;The association table of dining role and cuisine items
     *
     * @param bo query condition
     * @return ums_role_cuisine;The association table of dining role and cuisine list
     */
    List<RoleCuisineVo> queryList(RoleCuisineBo bo);

    /**
     * Add ums_role_cuisine;The association table of dining role and cuisine
     *
     * @param bo ums_role_cuisine;The association table of dining role and cuisine
     * @return if the add operation is successful
     */
    Boolean insertByBo(RoleCuisineBo bo);

    /**
     * Modify ums_role_cuisine;The association table of dining role and cuisine
     *
     * @param bo ums_role_cuisine;The association table of dining role and cuisine
     * @return if the modification is successful
     */
    Boolean updateByBo(RoleCuisineBo bo);

    /**
     * Verify and batch delete ums_role_cuisine;The association table of dining role and cuisine information
     *
     * @param ids     primary keys to be deleted
     * @param isValid whether to conduct a validation of effectiveness
     * @return if the delete operation is successful
     */
    Boolean deleteWithValidByIds(Collection<Long> ids, Boolean isValid);
}
