package com.calotter.cook.service;

import com.calotter.cook.domain.vo.SessionVo;
import com.calotter.cook.domain.bo.SessionBo;
import com.calotter.common.mybatis.core.page.TableDataInfo;
import com.calotter.common.mybatis.core.page.PageQuery;

import java.util.Collection;
import java.util.List;

/**
 * cms_session;This table records the start and end times for all users cooking sessions, along with which meal they prepared. service interface
 *
 * @author Ruoyu Ji
 */
public interface ISessionService {

    /**
     * Query cms_session;This table records the start and end times for all users cooking sessions, along with which meal they prepared.
     *
     * @param id primary key
     * @return cms_session;This table records the start and end times for all users cooking sessions, along with which meal they prepared.
     */
    SessionVo queryById(Long id);

    /**
     * Pagination query cms_session;This table records the start and end times for all users cooking sessions, along with which meal they prepared. list
     *
     * @param bo        query condition
     * @param pageQuery pagination parameters
     * @return cms_session;This table records the start and end times for all users cooking sessions, along with which meal they prepared. paged list
     */
    TableDataInfo<SessionVo> queryPageList(SessionBo bo, PageQuery pageQuery);

    /**
     * Query the list of eligible cms_session;This table records the start and end times for all users cooking sessions, along with which meal they prepared. items
     *
     * @param bo query condition
     * @return cms_session;This table records the start and end times for all users cooking sessions, along with which meal they prepared. list
     */
    List<SessionVo> queryList(SessionBo bo);

    /**
     * Add cms_session;This table records the start and end times for all users cooking sessions, along with which meal they prepared.
     *
     * @param bo cms_session;This table records the start and end times for all users cooking sessions, along with which meal they prepared.
     * @return if the add operation is successful
     */
    Boolean insertByBo(SessionBo bo);

    /**
     * Modify cms_session;This table records the start and end times for all users cooking sessions, along with which meal they prepared.
     *
     * @param bo cms_session;This table records the start and end times for all users cooking sessions, along with which meal they prepared.
     * @return if the modification is successful
     */
    Boolean updateByBo(SessionBo bo);

    /**
     * Verify and batch delete cms_session;This table records the start and end times for all users cooking sessions, along with which meal they prepared. information
     *
     * @param ids     primary keys to be deleted
     * @param isValid whether to conduct a validation of effectiveness
     * @return if the delete operation is successful
     */
    Boolean deleteWithValidByIds(Collection<Long> ids, Boolean isValid);
}
