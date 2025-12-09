package com.calotter.user.service;

import com.calotter.user.domain.vo.PreferenceVo;
import com.calotter.user.domain.bo.PreferenceBo;
import com.calotter.common.mybatis.core.page.TableDataInfo;
import com.calotter.common.mybatis.core.page.PageQuery;

import java.util.Collection;
import java.util.List;

/**
 * ums_preference;The global dietary preference of dining roles service interface
 *
 * @author Ruoyu Ji
 */
public interface IPreferenceService {

    /**
     * Query ums_preference;The global dietary preference of dining roles
     *
     * @param id primary key
     * @return ums_preference;The global dietary preference of dining roles
     */
    PreferenceVo queryById(Long id);

    /**
     * Pagination query ums_preference;The global dietary preference of dining roles list
     *
     * @param bo        query condition
     * @param pageQuery pagination parameters
     * @return ums_preference;The global dietary preference of dining roles paged list
     */
    TableDataInfo<PreferenceVo> queryPageList(PreferenceBo bo, PageQuery pageQuery);

    /**
     * Query the list of eligible ums_preference;The global dietary preference of dining roles items
     *
     * @param bo query condition
     * @return ums_preference;The global dietary preference of dining roles list
     */
    List<PreferenceVo> queryList(PreferenceBo bo);

    /**
     * Add ums_preference;The global dietary preference of dining roles
     *
     * @param bo ums_preference;The global dietary preference of dining roles
     * @return if the add operation is successful
     */
    Boolean insertByBo(PreferenceBo bo);

    /**
     * Modify ums_preference;The global dietary preference of dining roles
     *
     * @param bo ums_preference;The global dietary preference of dining roles
     * @return if the modification is successful
     */
    Boolean updateByBo(PreferenceBo bo);

    /**
     * Verify and batch delete ums_preference;The global dietary preference of dining roles information
     *
     * @param ids     primary keys to be deleted
     * @param isValid whether to conduct a validation of effectiveness
     * @return if the delete operation is successful
     */
    Boolean deleteWithValidByIds(Collection<Long> ids, Boolean isValid);
}
