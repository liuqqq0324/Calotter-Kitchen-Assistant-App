package com.calotter.user.service;

import com.calotter.user.domain.vo.RestrictionVo;
import com.calotter.user.domain.bo.RestrictionBo;
import com.calotter.common.mybatis.core.page.TableDataInfo;
import com.calotter.common.mybatis.core.page.PageQuery;

import java.util.Collection;
import java.util.List;

/**
 * ums_restriction;The global dietary restrictions of dining roles service interface
 *
 * @author Ruoyu Ji
 */
public interface IRestrictionService {

    /**
     * Query ums_restriction;The global dietary restrictions of dining roles
     *
     * @param id primary key
     * @return ums_restriction;The global dietary restrictions of dining roles
     */
    RestrictionVo queryById(Long id);

    /**
     * Pagination query ums_restriction;The global dietary restrictions of dining roles list
     *
     * @param bo        query condition
     * @param pageQuery pagination parameters
     * @return ums_restriction;The global dietary restrictions of dining roles paged list
     */
    TableDataInfo<RestrictionVo> queryPageList(RestrictionBo bo, PageQuery pageQuery);

    /**
     * Query the list of eligible ums_restriction;The global dietary restrictions of dining roles items
     *
     * @param bo query condition
     * @return ums_restriction;The global dietary restrictions of dining roles list
     */
    List<RestrictionVo> queryList(RestrictionBo bo);

    /**
     * Add ums_restriction;The global dietary restrictions of dining roles
     *
     * @param bo ums_restriction;The global dietary restrictions of dining roles
     * @return if the add operation is successful
     */
    Boolean insertByBo(RestrictionBo bo);

    /**
     * Modify ums_restriction;The global dietary restrictions of dining roles
     *
     * @param bo ums_restriction;The global dietary restrictions of dining roles
     * @return if the modification is successful
     */
    Boolean updateByBo(RestrictionBo bo);

    /**
     * Verify and batch delete ums_restriction;The global dietary restrictions of dining roles information
     *
     * @param ids     primary keys to be deleted
     * @param isValid whether to conduct a validation of effectiveness
     * @return if the delete operation is successful
     */
    Boolean deleteWithValidByIds(Collection<Long> ids, Boolean isValid);
}
