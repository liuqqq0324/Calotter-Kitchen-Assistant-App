package com.calotter.cook.mapper;

import com.calotter.cook.domain.Session;
import com.calotter.cook.domain.vo.SessionVo;
import com.calotter.common.mybatis.core.mapper.BaseMapperPlus;

/**
 * cms_session;This table records the start and end times for all users cooking sessions, along with which meal they prepared. mapper interface
 *
 * @author Ruoyu Ji
 */
public interface SessionMapper extends BaseMapperPlus<Session, SessionVo> {

}
