package com.calotter.cook.service;

import com.calotter.cook.domain.vo.SessionRecipeVo;
import com.calotter.cook.domain.bo.SessionRecipeBo;
import com.calotter.common.mybatis.core.page.TableDataInfo;
import com.calotter.common.mybatis.core.page.PageQuery;

import java.util.Collection;
import java.util.List;

/**
 * cms_session_recipe;This table stores all associated data regarding the specific dishes included in a particular meal prepared by the user. service interface
 *
 * @author Ruoyu Ji
 */
public interface ISessionRecipeService {

    /**
     * Query cms_session_recipe;This table stores all associated data regarding the specific dishes included in a particular meal prepared by the user.
     *
     * @param id primary key
     * @return cms_session_recipe;This table stores all associated data regarding the specific dishes included in a particular meal prepared by the user.
     */
    SessionRecipeVo queryById(Long id);

    /**
     * Pagination query cms_session_recipe;This table stores all associated data regarding the specific dishes included in a particular meal prepared by the user. list
     *
     * @param bo        query condition
     * @param pageQuery pagination parameters
     * @return cms_session_recipe;This table stores all associated data regarding the specific dishes included in a particular meal prepared by the user. paged list
     */
    TableDataInfo<SessionRecipeVo> queryPageList(SessionRecipeBo bo, PageQuery pageQuery);

    /**
     * Query the list of eligible cms_session_recipe;This table stores all associated data regarding the specific dishes included in a particular meal prepared by the user. items
     *
     * @param bo query condition
     * @return cms_session_recipe;This table stores all associated data regarding the specific dishes included in a particular meal prepared by the user. list
     */
    List<SessionRecipeVo> queryList(SessionRecipeBo bo);

    /**
     * Add cms_session_recipe;This table stores all associated data regarding the specific dishes included in a particular meal prepared by the user.
     *
     * @param bo cms_session_recipe;This table stores all associated data regarding the specific dishes included in a particular meal prepared by the user.
     * @return if the add operation is successful
     */
    Boolean insertByBo(SessionRecipeBo bo);

    /**
     * Modify cms_session_recipe;This table stores all associated data regarding the specific dishes included in a particular meal prepared by the user.
     *
     * @param bo cms_session_recipe;This table stores all associated data regarding the specific dishes included in a particular meal prepared by the user.
     * @return if the modification is successful
     */
    Boolean updateByBo(SessionRecipeBo bo);

    /**
     * Verify and batch delete cms_session_recipe;This table stores all associated data regarding the specific dishes included in a particular meal prepared by the user. information
     *
     * @param ids     primary keys to be deleted
     * @param isValid whether to conduct a validation of effectiveness
     * @return if the delete operation is successful
     */
    Boolean deleteWithValidByIds(Collection<Long> ids, Boolean isValid);
}
