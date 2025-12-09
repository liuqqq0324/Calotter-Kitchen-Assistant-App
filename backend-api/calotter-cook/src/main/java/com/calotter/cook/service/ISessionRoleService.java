package com.calotter.cook.service;

import com.calotter.cook.domain.vo.SessionRoleVo;
import com.calotter.cook.domain.bo.SessionRoleBo;
import com.calotter.common.mybatis.core.page.TableDataInfo;
import com.calotter.common.mybatis.core.page.PageQuery;

import java.util.Collection;
import java.util.List;

/**
 * cms_session_role;Association table that stores the relation of role and cooking history, with optional feedback from the role. service interface
 *
 * @author Ruoyu Ji
 */
public interface ISessionRoleService {

    /**
     * Query cms_session_role;Association table that stores the relation of role and cooking history, with optional feedback from the role.
     *
     * @param id primary key
     * @return cms_session_role;Association table that stores the relation of role and cooking history, with optional feedback from the role.
     */
    SessionRoleVo queryById(Long id);

    /**
     * Pagination query cms_session_role;Association table that stores the relation of role and cooking history, with optional feedback from the role. list
     *
     * @param bo        query condition
     * @param pageQuery pagination parameters
     * @return cms_session_role;Association table that stores the relation of role and cooking history, with optional feedback from the role. paged list
     */
    TableDataInfo<SessionRoleVo> queryPageList(SessionRoleBo bo, PageQuery pageQuery);

    /**
     * Query the list of eligible cms_session_role;Association table that stores the relation of role and cooking history, with optional feedback from the role. items
     *
     * @param bo query condition
     * @return cms_session_role;Association table that stores the relation of role and cooking history, with optional feedback from the role. list
     */
    List<SessionRoleVo> queryList(SessionRoleBo bo);

    /**
     * Add cms_session_role;Association table that stores the relation of role and cooking history, with optional feedback from the role.
     *
     * @param bo cms_session_role;Association table that stores the relation of role and cooking history, with optional feedback from the role.
     * @return if the add operation is successful
     */
    Boolean insertByBo(SessionRoleBo bo);

    /**
     * Modify cms_session_role;Association table that stores the relation of role and cooking history, with optional feedback from the role.
     *
     * @param bo cms_session_role;Association table that stores the relation of role and cooking history, with optional feedback from the role.
     * @return if the modification is successful
     */
    Boolean updateByBo(SessionRoleBo bo);

    /**
     * Verify and batch delete cms_session_role;Association table that stores the relation of role and cooking history, with optional feedback from the role. information
     *
     * @param ids     primary keys to be deleted
     * @param isValid whether to conduct a validation of effectiveness
     * @return if the delete operation is successful
     */
    Boolean deleteWithValidByIds(Collection<Long> ids, Boolean isValid);
}
