package com.calotter.cook.mapper;

import com.calotter.cook.domain.SessionRole;
import com.calotter.cook.domain.vo.SessionRoleVo;
import com.calotter.common.mybatis.core.mapper.BaseMapperPlus;

/**
 * cms_session_role;Association table that stores the relation of role and cooking history, with optional feedback from the role. mapper interface
 *
 * @author Ruoyu Ji
 */
public interface SessionRoleMapper extends BaseMapperPlus<SessionRole, SessionRoleVo> {

}
