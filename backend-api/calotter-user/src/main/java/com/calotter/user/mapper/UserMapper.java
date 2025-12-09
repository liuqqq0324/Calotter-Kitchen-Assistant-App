package com.calotter.user.mapper;

import com.calotter.user.domain.User;
import com.calotter.user.domain.vo.UserVo;
import com.calotter.common.mybatis.core.mapper.BaseMapperPlus;

/**
 * ums_user;This table is the master user table, storing the basic information of all users. mapper interface
 *
 * @author Ruoyu Ji
 */
public interface UserMapper extends BaseMapperPlus<User, UserVo> {

}
